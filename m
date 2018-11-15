Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7CEE16B0003
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 03:30:48 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id c203-v6so14465758ywh.8
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 00:30:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c190-v6sor1105137ybh.57.2018.11.15.00.30.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Nov 2018 00:30:46 -0800 (PST)
MIME-Version: 1.0
References: <CAJtqMcZp5AVva2yOM4gJET8Gd_j_BGJDLTkcqRdJynVCiRRFxQ@mail.gmail.com>
 <20181113130433.GB16182@dhcp22.suse.cz> <CAJtqMcY98hARD-_FmGYt875Tr6qmMP+42O7OWXNny6rD8ag91A@mail.gmail.com>
 <dc39308b-1b9e-0cce-471c-64f94f631f97@oracle.com>
In-Reply-To: <dc39308b-1b9e-0cce-471c-64f94f631f97@oracle.com>
From: Yongkai Wu <nic.wuyk@gmail.com>
Date: Thu, 15 Nov 2018 16:30:32 +0800
Message-ID: <CAJtqMcYzA6c1pTrWPcPETsJchOjpJS8iXVhDAJyWuVGCA4gKuA@mail.gmail.com>
Subject: Re: [PATCH] mm/hugetl.c: keep the page mapping info when
 free_huge_page() hit the VM_BUG_ON_PAGE
Content-Type: multipart/alternative; boundary="000000000000071edd057aafde9e"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mike.kravetz@oracle.com
Cc: mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--000000000000071edd057aafde9e
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Dear Maintainer,
The following is the detail information of the issue i meet.
It may be too boring to read,but i try to explain it more detail.



We use centos 7.4(kernel version:3.10.0-693.el7.x86_64).
Several days ago,i met a kernel panic issue,the kernel log showed:

[759990.616719] EDAC MC2: 51 CE memory read error on
CPU_SrcID#1_MC#0_Chan#1_DIMM#0 (channel:1 slot:0 page:0x4dd4f69
offset:0xcc0 grain:32 syndrome:0x0 -  OVERFLOW err_code:0101:0091 socket:1
imc:0 rank:0 bg:1 ba:1 row:1371a col:1a8)
[759990.627721] soft offline: 0x4dd4f69: migration failed 1, type
6fffff00008000
[759990.627743] ------------[ cut here ]------------
[759990.627763] kernel BUG at
/data/rpmbuild/BUILD/kernel-3.10.0/kernel-3.10.0/mm/hugetlb.c:1250!
[759990.628390] CPU: 27 PID: 457768 Comm: mcelog
[759990.628413] Hardware name: Lenovo HR650X           /HR650X     , BIOS
HR6N0333 06/23/2018
[759990.628433] task: ffff882f7f4f4f10 ti: ffff883326f10000 task.ti:
ffff883326f10000
[759990.628452] RIP: 0010:[<ffffffff811cc094>]  [<ffffffff811cc094>]
free_huge_page+0x1e4/0x200
[759990.628479] RSP: 0018:ffff883326f13d80  EFLAGS: 00010213
[759990.628493] RAX: 0000000000000001 RBX: ffffea0137000000 RCX:
0000000000000012
[759990.628511] RDX: 0000000040000000 RSI: ffffffff81f55500 RDI:
ffffea0137000000
[759990.628529] RBP: ffff883326f13da8 R08: ffffffff81f4e0e8 R09:
0000000000000000
......
[759990.628741] Call Trace:
[759990.628752]  [<ffffffff8169fe6a>] __put_compound_page+0x1f/0x22
[759990.628768]  [<ffffffff8169fea2>] put_compound_page+0x35/0x174
[759990.628786]  [<ffffffff811905a5>] put_page+0x45/0x50
[759990.629591]  [<ffffffff811d09a0>] putback_active_hugepage+0xd0/0xf0
[759990.630365]  [<ffffffff811fa0eb>] soft_offline_page+0x4db/0x580
[759990.631134]  [<ffffffff81453595>] store_soft_offline_page+0xa5/0xe0
[759990.631900]  [<ffffffff8143a298>] dev_attr_store+0x18/0x30
[759990.632660]  [<ffffffff81280486>] sysfs_write_file+0xc6/0x140
[759990.633409]  [<ffffffff8120101d>] vfs_write+0xbd/0x1e0
[759990.634148]  [<ffffffff81201e2f>] SyS_write+0x7f/0xe0
[759990.634870]  [<ffffffff816b4849>] system_call_fastpath+0x16/0x1b




I check the coredump,by disassembly free_huge_page() :
0xffffffff811cbf78 <free_huge_page+0xc8>:       cmp    $0xffffffff,%eax
0xffffffff811cbf7b <free_huge_page+0xcb>:       jne    0xffffffff811cc094
<free_huge_page+0x1e4>
......
0xffffffff811cc094 <free_huge_page+0x1e4>:    ud2


and check the sourcecode,i can only know that the panic reason is:
page->_count=3D0 but page->_mapcount=3D1,so hit the
BUG_ON(page_mapcount(page));
But can not get any further clue how the issue happen.




So i modify the code as the patch show,and apply the new code to our
produce line and wait some days,then the issue come again on another server=
.
And this time,by analyse the coredump using crash tool,i can know the whole
file path which trigger the issue.
For example:
crash> page.mapping ffffea02f9000000
      mapping =3D 0xffff88b098ae8160
crash> address_space.host 0xffff88b098ae8160
      host =3D 0xffff88b098ae8010
crash> inode.i_dentry 0xffff88b098ae8010
        i_dentry =3D {
              first =3D 0xffff88b0bbeb58b0
        }
crash> dentry.d_name.name -l dentry.d_alias 0xffff88b0bbeb58b0
       d_name.name =3D 0xffff88b0bbeb5838 "file_a"

So i can know the issue happen when doing soft offline to the page of the
file "file_a".
And i can also know the whole file path by list the dentry.d_parent and
check the dentry name.




Check with other team,i know that their user component will use file_a all
the time,
so the page->_mapcount not equal to -1 seems normal,and page->_count=3D0 is
abnormal at that time.

I guess if i triggeer a soft offline to the physical addr of the page using
by file_a,maybe the issue can reproduce.
So i write a user application to mmap to file_a and get the physical addr
of the page,the key step just as the following:
      fd =3D open(FILE_A_PATH,O_RDWR,0666);
      buf =3D mmap(NULL, pagesize, PROT_READ, MAP_SHARED, fd, 0);
      phys_addr =3D vtop((unsigned long long)buf);
In the function vtop(),i use "/proc/pid/pagemap" to get the physical addr
of the page.

Suppose that the physical addr is 0xbe40000000,then i can trigger a soft
offline to the addr:
        echo 0xbe40000000 > /sys/devices/system/memory/soft_offline_page
And after i trigger two or more times,the issue reproduce.





Then i use systemtap to probe page->_count and page->_mapcount in the
fucntions soft_offline_page(),putback_active_hugepage() and migrate_pages()
part of my systemtap script:

function get_page_mapcount:long (page:long) %{
    struct page *page;

    page =3D (struct page *)STAP_ARG_page;
    if(page =3D=3D NULL)
        STAP_RETURN(NULL);
    else
        STAP_RETURN(page_mapcount(page)-1);
%}

probe kernel.function("migrate_pages")
{
    page2 =3D get_page_from_migrate_pages($from);
    printf("Now exec migrate_pages --
page=3D%p,pfn=3D%ld,phy_addr=3D0x%lx,page_flags=3D0x%lx\n",page2,get_page_p=
fn(page2),get_page_phy_addr(page2),get_page_flags(page2));

printf("page->mapping=3D%p,page->_count=3D%d,page->_mapcount=3D%d\n",get_pa=
ge_mapping(page2),get_page_count(page2),get_page_mapcount(page2));
    print_backtrace();
}

Then i trigger soft offline to reproduce the issue,and finally find the
root cause:
In centos 7.4,when run into soft_offline_huge_page(),get_any_page() only
increase the page->_count by 1,
(isolate_huge_page() will also inc page->_count by 1 but then put_page()
will release the ref)

because we use 1 GB size of hugepage,so hugepage_migration_supported() will
always return false,
so soft_offline_huge_page() -->  migrate_pages() -->
unmap_and_move_huge_page() will call putback_active_hugepage() to decrease
page->_count by 1 just as the code show:
static int unmap_and_move_huge_page(new_page_t get_new_page,
{
......
if (!hugepage_migration_supported(page_hstate(hpage))) {
    putback_active_hugepage(hpage);   // =3D=3D> will decrease page->_count=
 by 1
    return -ENOSYS;
}
......

Then when return to soft_offline_huge_page,page->_count will be decrease by
1 again by putback_active_hugepage():
static int soft_offline_huge_page(struct page *page, int flags)
{
     ret =3D migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
     MIGRATE_SYNC, MR_MEMORY_FAILURE);
     if (ret) {
         pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
         pfn, ret, page->flags);
         putback_active_hugepage(hpage);  // =3D=3D> here will decrease
page->_count by 1 again
         ......
     } else {
           ......
     }
}


So we can know when call soft_offline_page() to the 1 GB size of
hugepage,page->_count will be abnormally decrease by 1!



=E3=80=90  I remove one putback_active_hugepage() in soft_offline_huge_page=
() to
fix this issue.  =E3=80=91

And i check the latest kernel code on git hub(4.19),it seems already fix
this issue by the following code:
static int soft_offline_huge_page(struct page *page, int flags)
{
     ret =3D migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
     MIGRATE_SYNC, MR_MEMORY_FAILURE);
     if (ret) {
         pr_info("soft offline: %#lx: hugepage migration failed %d, type
%lx (%pGp)\n",
             pfn, ret, page->flags, &page->flags);
         if (!list_empty(&pagelist))             // =3D=3D> seems this code=
 can
fix the issue i meet
             putback_movable_pages(&pagelist);
         if (ret > 0)
         ret =3D -EIO;
     } else {
     }
}
But i can not find a similar bug fix report or commit log.

--000000000000071edd057aafde9e
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Dear Maintainer,<div>The following is the detail informati=
on of the issue i meet.</div><div>It may be too boring to read,but i try to=
 explain it more detail.</div><div><br></div><div><br></div><div><br></div>=
<div><div>We use centos 7.4(kernel version:3.10.0-693.el7.x86_64).</div><di=
v>Several days ago,i met a kernel panic issue,the kernel log showed:</div><=
div><br></div><div>[759990.616719] EDAC MC2: 51 CE memory read error on CPU=
_SrcID#1_MC#0_Chan#1_DIMM#0 (channel:1 slot:0 page:0x4dd4f69 offset:0xcc0 g=
rain:32 syndrome:0x0 -=C2=A0 OVERFLOW err_code:0101:0091 socket:1 imc:0 ran=
k:0 bg:1 ba:1 row:1371a col:1a8)</div><div>[759990.627721] soft offline: 0x=
4dd4f69: migration failed 1, type 6fffff00008000</div><div>[759990.627743] =
------------[ cut here ]------------</div><div>[759990.627763] kernel BUG a=
t /data/rpmbuild/BUILD/kernel-3.10.0/kernel-3.10.0/mm/hugetlb.c:1250!</div>=
<div>[759990.628390] CPU: 27 PID: 457768 Comm: mcelog</div><div>[759990.628=
413] Hardware name: Lenovo HR650X=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/=
HR650X=C2=A0 =C2=A0 =C2=A0, BIOS HR6N0333 06/23/2018</div><div>[759990.6284=
33] task: ffff882f7f4f4f10 ti: ffff883326f10000 task.ti: ffff883326f10000</=
div><div>[759990.628452] RIP: 0010:[&lt;ffffffff811cc094&gt;]=C2=A0 [&lt;ff=
ffffff811cc094&gt;] free_huge_page+0x1e4/0x200</div><div>[759990.628479] RS=
P: 0018:ffff883326f13d80=C2=A0 EFLAGS: 00010213</div><div>[759990.628493] R=
AX: 0000000000000001 RBX: ffffea0137000000 RCX: 0000000000000012</div><div>=
[759990.628511] RDX: 0000000040000000 RSI: ffffffff81f55500 RDI: ffffea0137=
000000</div><div>[759990.628529] RBP: ffff883326f13da8 R08: ffffffff81f4e0e=
8 R09: 0000000000000000</div><div>......</div><div>[759990.628741] Call Tra=
ce:</div><div>[759990.628752]=C2=A0 [&lt;ffffffff8169fe6a&gt;] __put_compou=
nd_page+0x1f/0x22</div><div>[759990.628768]=C2=A0 [&lt;ffffffff8169fea2&gt;=
] put_compound_page+0x35/0x174</div><div>[759990.628786]=C2=A0 [&lt;fffffff=
f811905a5&gt;] put_page+0x45/0x50</div><div>[759990.629591]=C2=A0 [&lt;ffff=
ffff811d09a0&gt;] putback_active_hugepage+0xd0/0xf0</div><div>[759990.63036=
5]=C2=A0 [&lt;ffffffff811fa0eb&gt;] soft_offline_page+0x4db/0x580</div><div=
>[759990.631134]=C2=A0 [&lt;ffffffff81453595&gt;] store_soft_offline_page+0=
xa5/0xe0</div><div>[759990.631900]=C2=A0 [&lt;ffffffff8143a298&gt;] dev_att=
r_store+0x18/0x30</div><div>[759990.632660]=C2=A0 [&lt;ffffffff81280486&gt;=
] sysfs_write_file+0xc6/0x140</div><div>[759990.633409]=C2=A0 [&lt;ffffffff=
8120101d&gt;] vfs_write+0xbd/0x1e0</div><div>[759990.634148]=C2=A0 [&lt;fff=
fffff81201e2f&gt;] SyS_write+0x7f/0xe0</div><div>[759990.634870]=C2=A0 [&lt=
;ffffffff816b4849&gt;] system_call_fastpath+0x16/0x1b</div><div><br></div><=
div><br></div><div><br></div><div><br></div><div>I check the coredump,by di=
sassembly free_huge_page() :</div><div>0xffffffff811cbf78 &lt;free_huge_pag=
e+0xc8&gt;:=C2=A0 =C2=A0 =C2=A0 =C2=A0cmp=C2=A0 =C2=A0 $0xffffffff,%eax</di=
v><div>0xffffffff811cbf7b &lt;free_huge_page+0xcb&gt;:=C2=A0 =C2=A0 =C2=A0 =
=C2=A0jne=C2=A0 =C2=A0 0xffffffff811cc094 &lt;free_huge_page+0x1e4&gt;</div=
><div>......</div><div>0xffffffff811cc094 &lt;free_huge_page+0x1e4&gt;:=C2=
=A0 =C2=A0 ud2</div><div><br></div><div><br></div><div>and check the source=
code,i can only know that the panic reason is:</div><div>page-&gt;_count=3D=
0 but page-&gt;_mapcount=3D1,so hit the</div><div>BUG_ON(page_mapcount(page=
));</div><div>But can not get any further clue how the issue happen.</div><=
div><br></div><div><br></div><div><br></div><div><br></div><div>So i modify=
 the code as the patch show,and apply the new code to our produce line and =
wait some days,then the issue come again on another server.</div><div>And t=
his time,by analyse the coredump using crash tool,i can know the whole file=
 path which trigger the issue.</div><div>For example:</div><div>crash&gt; p=
age.mapping ffffea02f9000000</div><div>=C2=A0 =C2=A0 =C2=A0 mapping =3D 0xf=
fff88b098ae8160</div><div>crash&gt; address_space.host 0xffff88b098ae8160</=
div><div>=C2=A0 =C2=A0 =C2=A0 host =3D 0xffff88b098ae8010</div><div>crash&g=
t; inode.i_dentry 0xffff88b098ae8010</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =
i_dentry =3D {</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 f=
irst =3D 0xffff88b0bbeb58b0</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 }</div><d=
iv>crash&gt; <a href=3D"http://dentry.d_name.name">dentry.d_name.name</a> -=
l dentry.d_alias 0xffff88b0bbeb58b0</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0<a=
 href=3D"http://d_name.name">d_name.name</a> =3D 0xffff88b0bbeb5838 &quot;f=
ile_a&quot;</div><div><br></div><div>So i can know the issue happen when do=
ing soft offline to the page of the file &quot;file_a&quot;.</div><div>And =
i can also know the whole file path by list the dentry.d_parent and check t=
he dentry name.</div><div><br></div><div><br></div><div><br></div><div><br>=
</div><div>Check with other team,i know that their user component will use =
file_a all the time,</div><div>so the page-&gt;_mapcount not equal to -1 se=
ems normal,and page-&gt;_count=3D0 is abnormal at that time.</div><div><br>=
</div><div>I guess if i triggeer a soft offline to the physical addr of the=
 page using by file_a,maybe the issue can reproduce.</div><div>So i write a=
 user application to mmap to file_a and get the physical addr of the page,t=
he key step just as the following:</div><div>=C2=A0 =C2=A0 =C2=A0 fd =3D op=
en(FILE_A_PATH,O_RDWR,0666);</div><div>=C2=A0 =C2=A0 =C2=A0 buf =3D mmap(NU=
LL, pagesize, PROT_READ, MAP_SHARED, fd, 0);</div><div>=C2=A0 =C2=A0 =C2=A0=
 phys_addr =3D vtop((unsigned long long)buf);</div><div>In the function vto=
p(),i use &quot;/proc/pid/pagemap&quot; to get the physical addr of the pag=
e.</div><div><br></div><div>Suppose that the physical addr is 0xbe40000000,=
then i can trigger a soft offline to the addr:</div><div>=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 echo 0xbe40000000 &gt; /sys/devices/system/memory/soft_offline_p=
age</div><div>And after i trigger two or more times,the issue reproduce.</d=
iv><div><br></div><div><br></div><div><br></div><div><br></div><div><br></d=
iv><div>Then i use systemtap to probe page-&gt;_count and page-&gt;_mapcoun=
t in the fucntions soft_offline_page(),putback_active_hugepage() and migrat=
e_pages()</div><div>part of my systemtap script:</div><div><br></div><div>f=
unction get_page_mapcount:long (page:long) %{</div><div>=C2=A0 =C2=A0 struc=
t page *page;</div><div><br></div><div>=C2=A0 =C2=A0 page =3D (struct page =
*)STAP_ARG_page;</div><div>=C2=A0 =C2=A0 if(page =3D=3D NULL)</div><div>=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 STAP_RETURN(NULL);</div><div>=C2=A0 =C2=A0 else</d=
iv><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 STAP_RETURN(page_mapcount(page)-1);</di=
v><div>%}</div><div><br></div><div>probe kernel.function(&quot;migrate_page=
s&quot;)</div><div>{</div><div>=C2=A0 =C2=A0 page2 =3D get_page_from_migrat=
e_pages($from);</div><div>=C2=A0 =C2=A0 printf(&quot;Now exec migrate_pages=
 -- page=3D%p,pfn=3D%ld,phy_addr=3D0x%lx,page_flags=3D0x%lx\n&quot;,page2,g=
et_page_pfn(page2),get_page_phy_addr(page2),get_page_flags(page2));</div><d=
iv>=C2=A0 =C2=A0 printf(&quot;page-&gt;mapping=3D%p,page-&gt;_count=3D%d,pa=
ge-&gt;_mapcount=3D%d\n&quot;,get_page_mapping(page2),get_page_count(page2)=
,get_page_mapcount(page2));</div><div>=C2=A0 =C2=A0 print_backtrace();</div=
><div>}</div><div><br></div><div>Then i trigger soft offline to reproduce t=
he issue,and finally find the root cause:</div><div>In centos 7.4,when run =
into soft_offline_huge_page(),get_any_page() only increase the page-&gt;_co=
unt by 1,</div><div>(isolate_huge_page() will also inc page-&gt;_count by 1=
 but then put_page() will release the ref)</div><div><br></div><div>because=
 we use 1 GB size of hugepage,so hugepage_migration_supported() will always=
 return false,</div><div>so soft_offline_huge_page() --&gt;=C2=A0 migrate_p=
ages() --&gt; unmap_and_move_huge_page() will call putback_active_hugepage(=
) to decrease page-&gt;_count by 1 just as the code show:</div><div>static =
int unmap_and_move_huge_page(new_page_t get_new_page,</div><div>{</div><div=
>......</div><div><span style=3D"white-space:pre">	</span>if (!hugepage_mig=
ration_supported(page_hstate(hpage))) {</div><div><span style=3D"white-spac=
e:pre">		</span>=C2=A0 =C2=A0 putback_active_hugepage(hpage);=C2=A0 =C2=A0/=
/ =3D=3D&gt; will decrease page-&gt;_count by 1</div><div><span style=3D"wh=
ite-space:pre">		</span>=C2=A0 =C2=A0 return -ENOSYS;</div><div><span style=
=3D"white-space:pre">	</span>}</div><div>......</div><div><br></div><div>Th=
en when return to soft_offline_huge_page,page-&gt;_count will be decrease b=
y 1 again by putback_active_hugepage():</div><div>static int soft_offline_h=
uge_page(struct page *page, int flags)</div><div>{</div><div>=C2=A0 =C2=A0=
=C2=A0<span style=3D"white-space:pre">	</span>ret =3D migrate_pages(&amp;pa=
gelist, new_page, MPOL_MF_MOVE_ALL,</div><div>=C2=A0 =C2=A0=C2=A0<span styl=
e=3D"white-space:pre">				</span>MIGRATE_SYNC, MR_MEMORY_FAILURE);</div><di=
v>=C2=A0 =C2=A0=C2=A0<span style=3D"white-space:pre">	</span>if (ret) {</di=
v><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0<span style=3D"white-space:pre">		<=
/span>pr_info(&quot;soft offline: %#lx: migration failed %d, type %lx\n&quo=
t;,</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0<span style=3D"white-space:p=
re">			</span>pfn, ret, page-&gt;flags);</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=
=A0=C2=A0<span style=3D"white-space:pre">		</span>putback_active_hugepage(h=
page);=C2=A0 // =3D=3D&gt; here will decrease page-&gt;_count by 1 again</d=
iv><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0<span style=3D"white-space:pre">		=
</span>......</div><div>=C2=A0 =C2=A0=C2=A0<span style=3D"white-space:pre">=
	</span>} else {</div><div>=C2=A0 =C2=A0=C2=A0<span style=3D"white-space:pr=
e">	</span>=C2=A0 =C2=A0 =C2=A0 ......</div><div>=C2=A0 =C2=A0=C2=A0<span s=
tyle=3D"white-space:pre">	</span>}</div><div>}</div><div><br></div><div><br=
></div><div>So we can know when call soft_offline_page() to the 1 GB size o=
f hugepage,page-&gt;_count will be abnormally decrease by 1!</div><div><br>=
</div><div><br></div><div><br></div><div>=E3=80=90=C2=A0 I remove one putba=
ck_active_hugepage() in soft_offline_huge_page() to fix this issue.=C2=A0 =
=E3=80=91</div><div><br></div><div>And i check the latest kernel code on gi=
t hub(4.19),it seems already fix this issue by the following code:</div><di=
v>static int soft_offline_huge_page(struct page *page, int flags)</div><div=
>{</div><div>=C2=A0 =C2=A0=C2=A0<span style=3D"white-space:pre">	</span>ret=
 =3D migrate_pages(&amp;pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,</div><d=
iv>=C2=A0 =C2=A0=C2=A0<span style=3D"white-space:pre">				</span>MIGRATE_SY=
NC, MR_MEMORY_FAILURE);</div><div>=C2=A0 =C2=A0=C2=A0<span style=3D"white-s=
pace:pre">	</span>if (ret) {</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0<sp=
an style=3D"white-space:pre">		</span>pr_info(&quot;soft offline: %#lx: hug=
epage migration failed %d, type %lx (%pGp)\n&quot;,</div><div>=C2=A0 =C2=A0=
 =C2=A0 =C2=A0=C2=A0<span style=3D"white-space:pre">			</span>=C2=A0 =C2=A0=
 pfn, ret, page-&gt;flags, &amp;page-&gt;flags);</div><div>=C2=A0 =C2=A0 =
=C2=A0 =C2=A0=C2=A0<span style=3D"white-space:pre">		</span>if (!list_empty=
(&amp;pagelist))=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0// =3D=3D&g=
t; seems this code can fix the issue i meet</div><div>=C2=A0 =C2=A0 =C2=A0 =
=C2=A0=C2=A0<span style=3D"white-space:pre">			</span>=C2=A0 =C2=A0 putback=
_movable_pages(&amp;pagelist);</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0<=
span style=3D"white-space:pre">		</span>if (ret &gt; 0)</div><div>=C2=A0 =
=C2=A0 =C2=A0 =C2=A0=C2=A0<span style=3D"white-space:pre">			</span>ret =3D=
 -EIO;</div><div>=C2=A0 =C2=A0=C2=A0<span style=3D"white-space:pre">	</span=
>} else {</div><div>=C2=A0 =C2=A0=C2=A0<span style=3D"white-space:pre">	</s=
pan>}</div><div>}</div><div>But i can not find a similar bug fix report or =
commit log.</div></div><br class=3D"gmail-Apple-interchange-newline"></div>

--000000000000071edd057aafde9e--
