Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 049EC6B025E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 14:44:25 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id n63so39432775ywf.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 11:44:24 -0700 (PDT)
Received: from mail-qt0-x22b.google.com (mail-qt0-x22b.google.com. [2607:f8b0:400d:c0d::22b])
        by mx.google.com with ESMTPS id c17si1426425qkj.139.2016.06.08.11.44.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 11:44:24 -0700 (PDT)
Received: by mail-qt0-x22b.google.com with SMTP id c34so4092229qte.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 11:44:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160606135140.GA21513@node.shutemov.name>
References: <1463067672-134698-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CADf8yx+YMM7DZ8icem2RMQMgtJ8TfGCjGc56xUrBpeY1xLZ4SQ@mail.gmail.com> <20160606135140.GA21513@node.shutemov.name>
From: neha agarwal <neha.agbk@gmail.com>
Date: Wed, 8 Jun 2016 14:43:44 -0400
Message-ID: <CADf8yxLnAajuffiTPP+-5PsgDfDBtp9H-sVVXPrZQqg4P4D2mw@mail.gmail.com>
Subject: Re: [PATCHv8 00/32] THP-enabled tmpfs/shmem using compound pages
Content-Type: multipart/alternative; boundary=001a11490df2bf68ec0534c8b18c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

--001a11490df2bf68ec0534c8b18c
Content-Type: text/plain; charset=UTF-8

On Mon, Jun 6, 2016 at 9:51 AM, Kirill A. Shutemov <kirill@shutemov.name>
wrote:

> On Wed, May 25, 2016 at 03:11:55PM -0400, neha agarwal wrote:
> > Hi All,
> >
> > I have been testing Hugh's and Kirill's huge tmpfs patch sets with
> > Cassandra (NoSQL database). I am seeing significant performance gap
> between
> > these two implementations (~30%). Hugh's implementation performs better
> > than Kirill's implementation. I am surprised why I am seeing this
> > performance gap. Following is my test setup.
> >
> > Patchsets
> > ========
> > - For Hugh's:
> > I checked out 4.6-rc3, applied Hugh's preliminary patches (01 to 10
> > patches) from here: https://lkml.org/lkml/2016/4/5/792 and then applied
> the
> > THP patches posted on April 16 (01 to 29 patches).
> >
> > - For Kirill's:
> > I am using his branch  "git://
> > git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v8",
> which
> > is based off of 4.6-rc3, posted on May 12.
> >
> >
> > Khugepaged settings
> > ================
> > cd /sys/kernel/mm/transparent_hugepage
> > echo 10 >khugepaged/alloc_sleep_millisecs
> > echo 10 >khugepaged/scan_sleep_millisecs
> > echo 511 >khugepaged/max_ptes_none
> >
> >
> > Mount options
> > ===========
> > - For Hugh's:
> > sudo sysctl -w vm/shmem_huge=2
> > sudo mount -o remount,huge=1 /hugetmpfs
> >
> > - For Kirill's:
> > sudo mount -o remount,huge=always /hugetmpfs
> > echo force > /sys/kernel/mm/transparent_hugepage/shmem_enabled
> > echo 511 >khugepaged/max_ptes_swap
> >
> >
> > Workload Setting
> > =============
> > Please look at the attached setup document for Cassandra (NoSQL
> database):
> > cassandra-setup.txt
> >
> >
> > Machine setup
> > ===========
> > 36-core (72 hardware thread) dual-socket x86 server with 512 GB RAM
> running
> > Ubuntu. I use control groups for resource isolation. Server and client
> > threads run on different sockets. Frequency governor set to "performance"
> > to remove any performance fluctuations due to frequency variation.
> >
> >
> > Throughput numbers
> > ================
> > Hugh's implementation: 74522.08 ops/sec
> > Kirill's implementation: 54919.10 ops/sec
>
> In my setup I don't see the difference:
>
> v4.7-rc1 + my implementation:
> [OVERALL], RunTime(ms), 822862.0
> [OVERALL], Throughput(ops/sec), 60763.53021527304
> ShmemPmdMapped:  4999168 kB
>
> v4.6-rc2 + Hugh's implementation:
> [OVERALL], RunTime(ms), 833157.0
> [OVERALL], Throughput(ops/sec), 60012.698687042175
> ShmemPmdMapped:  5021696 kB
>
> It's basically within measuarment error. 'ShmemPmdMapped' indicate how
> much memory is mapped with huge pages by the end of test.
>
> It's on dual-socket 24-core machine with 64G of RAM.
>
> I guess we have some configuration difference or something, but so far I
> don't see the drastic performance difference you've pointed to.
>
> May be my implementation behaves slower on bigger machines, I don't know..
> There's no architectural reason for this.
>
> I'll post my updated patchset today.
>
> --
>  Kirill A. Shutemov
>

Thanks a lot Kirill for the testing. It is interesting that you don't see
any significant performance difference. Also, your absolute throughput
numbers are different from mine, more so for Hugh's implementation.

Can you please share your kernel config file? I will try to look if I have
some different config settings. Also, I am assuming that you had turned off
DVFS.

One thing I forgot mentioning in my previous setup email was: I use 8 cores
for running Cassandra server threads. Can you please tell how many cores
did you use? As Cassandra is CPU bound that can make a difference in
throughput number we are seeing.


-- 
Thanks and Regards,
Neha

--001a11490df2bf68ec0534c8b18c
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>On Mon, Jun 6, 2016 at 9:51 AM, Kirill A. Shutemov <s=
pan dir=3D"ltr">&lt;<a href=3D"mailto:kirill@shutemov.name" target=3D"_blan=
k">kirill@shutemov.name</a>&gt;</span> wrote:<br></div><div class=3D"gmail_=
extra"><div class=3D"gmail_quote"><blockquote class=3D"gmail_quote" style=
=3D"margin:0px 0px 0px 0.8ex;border-left-width:1px;border-left-style:solid;=
border-left-color:rgb(204,204,204);padding-left:1ex"><span class=3D"">On We=
d, May 25, 2016 at 03:11:55PM -0400, neha agarwal wrote:<br>
</span><span class=3D"">&gt; Hi All,<br>
&gt;<br>
&gt; I have been testing Hugh&#39;s and Kirill&#39;s huge tmpfs patch sets =
with<br>
&gt; Cassandra (NoSQL database). I am seeing significant performance gap be=
tween<br>
&gt; these two implementations (~30%). Hugh&#39;s implementation performs b=
etter<br>
&gt; than Kirill&#39;s implementation. I am surprised why I am seeing this<=
br>
&gt; performance gap. Following is my test setup.<br>
&gt;<br>
&gt; Patchsets<br>
&gt; =3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; - For Hugh&#39;s:<br>
&gt; I checked out 4.6-rc3, applied Hugh&#39;s preliminary patches (01 to 1=
0<br>
&gt; patches) from here: <a href=3D"https://lkml.org/lkml/2016/4/5/792" rel=
=3D"noreferrer" target=3D"_blank">https://lkml.org/lkml/2016/4/5/792</a> an=
d then applied the<br>
&gt; THP patches posted on April 16 (01 to 29 patches).<br>
&gt;<br>
&gt; - For Kirill&#39;s:<br>
&gt; I am using his branch=C2=A0 &quot;git://<br>
</span>&gt; <a href=3D"http://git.kernel.org/pub/scm/linux/kernel/git/kas/l=
inux.git" rel=3D"noreferrer" target=3D"_blank">git.kernel.org/pub/scm/linux=
/kernel/git/kas/linux.git</a> hugetmpfs/v8&quot;, which<br>
<div><div class=3D"h5">&gt; is based off of 4.6-rc3, posted on May 12.<br>
&gt;<br>
&gt;<br>
&gt; Khugepaged settings<br>
&gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; cd /sys/kernel/mm/transparent_hugepage<br>
&gt; echo 10 &gt;khugepaged/alloc_sleep_millisecs<br>
&gt; echo 10 &gt;khugepaged/scan_sleep_millisecs<br>
&gt; echo 511 &gt;khugepaged/max_ptes_none<br>
&gt;<br>
&gt;<br>
&gt; Mount options<br>
&gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; - For Hugh&#39;s:<br>
&gt; sudo sysctl -w vm/shmem_huge=3D2<br>
&gt; sudo mount -o remount,huge=3D1 /hugetmpfs<br>
&gt;<br>
&gt; - For Kirill&#39;s:<br>
&gt; sudo mount -o remount,huge=3Dalways /hugetmpfs<br>
&gt; echo force &gt; /sys/kernel/mm/transparent_hugepage/shmem_enabled<br>
&gt; echo 511 &gt;khugepaged/max_ptes_swap<br>
&gt;<br>
&gt;<br>
&gt; Workload Setting<br>
&gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; Please look at the attached setup document for Cassandra (NoSQL databa=
se):<br>
&gt; cassandra-setup.txt<br>
&gt;<br>
&gt;<br>
&gt; Machine setup<br>
&gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; 36-core (72 hardware thread) dual-socket x86 server with 512 GB RAM ru=
nning<br>
&gt; Ubuntu. I use control groups for resource isolation. Server and client=
<br>
&gt; threads run on different sockets. Frequency governor set to &quot;perf=
ormance&quot;<br>
&gt; to remove any performance fluctuations due to frequency variation.<br>
&gt;<br>
&gt;<br>
&gt; Throughput numbers<br>
&gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; Hugh&#39;s implementation: 74522.08 ops/sec<br>
&gt; Kirill&#39;s implementation: 54919.10 ops/sec<br>
<br>
</div></div>In my setup I don&#39;t see the difference:<br>
<br>
v4.7-rc1 + my implementation:<br>
[OVERALL], RunTime(ms), 822862.0<br>
[OVERALL], Throughput(ops/sec), 60763.53021527304<br>
ShmemPmdMapped:=C2=A0 4999168 kB<br>
<br>
v4.6-rc2 + Hugh&#39;s implementation:<br>
[OVERALL], RunTime(ms), 833157.0<br>
[OVERALL], Throughput(ops/sec), 60012.698687042175<br>
ShmemPmdMapped:=C2=A0 5021696 kB<br>
<br>
It&#39;s basically within measuarment error. &#39;ShmemPmdMapped&#39; indic=
ate how<br>
much memory is mapped with huge pages by the end of test.<br>
<br>
It&#39;s on dual-socket 24-core machine with 64G of RAM.<br>
<br>
I guess we have some configuration difference or something, but so far I<br=
>
don&#39;t see the drastic performance difference you&#39;ve pointed to.<br>
<br>
May be my implementation behaves slower on bigger machines, I don&#39;t kno=
w..<br>
There&#39;s no architectural reason for this.<br>
<br>
I&#39;ll post my updated patchset today.<br>
<span class=3D""><font color=3D"#888888"><br>
--<br>
=C2=A0Kirill A. Shutemov<br>
</font></span></blockquote></div><div class=3D"gmail_extra"><br></div><div>=
<span style=3D"font-size:12.8px">Thanks a lot Kirill for the testing. It is=
 interesting that you don&#39;t see any significant performance difference.=
 Also, your absolute throughput numbers are different from mine, more so fo=
r Hugh&#39;s implementation.</span></div><div><span style=3D"font-size:12.8=
px"><br></span></div><div><span style=3D"font-size:12.8px">Can you please s=
hare your kernel config file? I will try to look if I have some different c=
onfig settings. Also, I am assuming that you had turned off DVFS.</span></d=
iv><div><span style=3D"font-size:12.8px"><br></span></div><div><span style=
=3D"font-size:12.8px">One thing I forgot mentioning in my previous setup em=
ail was: I use 8 cores for running Cassandra server threads. Can you please=
 tell how many cores did you use? As Cassandra is CPU bound that can make a=
 difference in throughput number we are seeing.=C2=A0</span></div><br clear=
=3D"all"><div><br></div>-- <br><div class=3D"gmail_signature" data-smartmai=
l=3D"gmail_signature"><div dir=3D"ltr">Thanks and Regards,<div>Neha</div></=
div></div>
</div></div>

--001a11490df2bf68ec0534c8b18c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
