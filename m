Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF0D96B2FBC
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 01:54:42 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id g188so3660807pgc.22
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 22:54:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r85sor32849106pfb.31.2018.11.22.22.54.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Nov 2018 22:54:40 -0800 (PST)
From: =?utf-8?B?5q6154aK5pil?= <duanxiongchun@bytedance.com>
Message-Id: <9D46FD61-1B9D-472F-AC6E-17C5780C2606@bytedance.com>
Content-Type: multipart/alternative;
	boundary="Apple-Mail=_9EAE8606-1E25-4E59-9C13-71579D139C8C"
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: [Bug 201699] New: kmemleak in memcg_create_kmem_cache
Date: Fri, 23 Nov 2018 14:54:35 +0800
In-Reply-To: <20181122073420.GB18011@dhcp22.suse.cz>
References: <20181116175005.3dcfpyhuj57oaszm@esperanza>
 <433c2924.f6c.16724466cd8.Coremail.bauers@126.com>
 <20181119083045.m5rhvbsze4h5l6jq@esperanza>
 <6185b79c.9161.1672bd49ed1.Coremail.bauers@126.com>
 <375ca28a.7433.16735734d98.Coremail.bauers@126.com>
 <20181121091041.GM12932@dhcp22.suse.cz>
 <5fa306b3.7c7c.1673593d0d8.Coremail.bauers@126.com>
 <556CF326-C3ED-44A7-909B-780531A8D4FF@bytedance.com>
 <20181121162747.GR12932@dhcp22.suse.cz>
 <7348A2DF-87E8-4F88-B270-7FB71DB5C8CB@bytedance.com>
 <20181122073420.GB18011@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: dong <bauers@126.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>


--Apple-Mail=_9EAE8606-1E25-4E59-9C13-71579D139C8C
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8

I had double check on the newest version 4.20-rc3

I had wrote a small test .


Test service code=20

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
int main()
{
	struct stat buf;
	int fd ;
	fd =3D =
open("/var/log/test",O_RDWR|O_CREAT|O_APPEND|O_CLOEXEC,0644);
	sleep(1);
	fd =3D open("/var/log/test.1", =
O_RDWR|O_CREAT|O_APPEND|O_CLOEXEC|O_SYNC, 0644);
	char log[4096] =3D {'a'};
	if (fd > 0) {
		write(fd, log, 4096);
		close(fd);
	}

	return 1;
}


Test.service=20

[Service]
ExecStart=3D/usr/bin/test
Restart=3Dalways
RestartSec=3D100ms
MemoryLimit=3D1G
StartLimitInterval=3D0
[Install]
WantedBy=3Ddefault.target

Probe code=20

Get test.1 node address kretprobe  code=20

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/seq_file.h>
#include <linux/proc_fs.h>
#include <linux/spinlock.h>

static struct kretprobe kprobe_ret_object =3D {
    .kp.symbol_name    =3D "d_lookup",
};

static int handler_d_lookup_pre(struct kretprobe_instance *p, struct =
pt_regs *regs)
{
	int *tmp;
	struct qstr * name =3D(struct qstr *)regs->si;
	tmp=3D(int *)p->data;
	*tmp=3D0;
	if(strcmp("test.1",name->name)=3D=3D0)
		*tmp=3D1;
	return 0;
}

static int ret_handler_d_lookup_pre(struct kretprobe_instance *p,struct =
pt_regs *regs)
{
	int *tmp;
	struct dentry * tmp_dentry =3D (struct dentry =
*)regs_return_value(regs);
	tmp =3D (int *)p->data;
	if(*tmp =3D=3D 1)
		printk(KERN_INFO "return dentry address %px,inode =
address %px\n",
			tmp_dentry,tmp_dentry->d_inode);
	return 0;
}
static int __init kprobe_init(void)
{
    int ret;
    kprobe_ret_object.entry_handler =3D handler_d_lookup_pre;
    kprobe_ret_object.handler =3D ret_handler_d_lookup_pre;
    kprobe_ret_object.maxactive =3D 0;
    kprobe_ret_object.data_size =3D sizeof(int);

    ret =3D register_kretprobe(&kprobe_ret_object);
    if (ret < 0) {
        printk(KERN_INFO "register_kprobe failed, returned %d\n", ret);
        return ret;
    }
    printk(KERN_INFO "Planted kprobe at %p\n", =
kprobe_ret_object.kp.addr);
    return 0;
}

static void __exit kprobe_exit(void)
{
    unregister_kretprobe(&kprobe_ret_object);
    printk(KERN_INFO "kprobe at %p unregistered\n", =
kprobe_ret_object.kp.addr);
}

module_init(kprobe_init)
module_exit(kprobe_exit)
MODULE_LICENSE("GPL=E2=80=9D);

Get unreleased mem_cgroup address

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/seq_file.h>
#include <linux/proc_fs.h>
#include <linux/spinlock.h>

static struct kretprobe css_alloc =3D {
    .kp.symbol_name    =3D "mem_cgroup_css_alloc",
};

static struct kprobe css_free =3D {
    .symbol_name    =3D "mem_cgroup_css_free",
};
static struct kprobe css_released =3D {
    .symbol_name    =3D "mem_cgroup_css_released",
};
static struct kprobe css_offline =3D {
    .symbol_name    =3D "mem_cgroup_css_offline",
};
static struct kprobe trycharge =3D {
    .symbol_name    =3D "page_counter_try_charge",
};
static struct kprobe charge =3D {
    .symbol_name    =3D "page_counter_charge",
};
static struct kprobe uncharge =3D {
    .symbol_name    =3D "page_counter_uncharge",
};

atomic_t cssalloc;
atomic_t cssfree;
atomic_t cssreleased;
atomic_t cssoffline;
static spinlock_t my_lock =3D __SPIN_LOCK_UNLOCKED();
void * css_addr=3D0;
void * memory_addr=3D0;

static int handler_trycharge(struct kprobe *p,struct pt_regs *regs)
{
    if (memory_addr =3D=3D (void *)(regs->di)){
	printk(KERN_INFO"trycharge_memory %px nr %px",(void =
*)memory_addr,(void *)regs->si);
	spin_lock(&my_lock);
	dump_stack();
	spin_unlock(&my_lock);
    }
    return 0;
}
static int handler_charge(struct kprobe *p,struct pt_regs *regs)
{
    if (memory_addr =3D=3D (void *)(regs->di)){
	printk(KERN_INFO"charge_memory %px,nr %px",(void =
*)memory_addr,(void *)regs->si);
	spin_lock(&my_lock);
	dump_stack();
	spin_unlock(&my_lock);
    }
    return 0;
}
static int handler_uncharge(struct kprobe *p,struct pt_regs *regs)
{
    if (memory_addr =3D=3D (void *)(regs->di)){
	printk(KERN_INFO"uncharge_memory %px,nr %px",(void =
*)memory_addr,(void *)regs->si);
	spin_lock(&my_lock);
	dump_stack();
	spin_unlock(&my_lock);
    }
    return 0;
}

static int handler_cssalloc_pre(struct kretprobe_instance *p, struct =
pt_regs *regs)
{
    atomic_inc(&cssalloc);
    return 0;
}

static int ret_handler_cssalloc_pre(struct kretprobe_instance *p,struct =
pt_regs *regs)
{
	if (css_addr=3D=3D0){
		css_addr=3D(void *)regs_return_value(regs);
		memory_addr=3D(void *)(regs_return_value(regs)+192);
	}
	return 0;
}

static int handler_cssfree_pre(struct kprobe *p,struct pt_regs *regs)
{
   atomic_inc(&cssfree);
    if (css_addr =3D=3D (void *)(regs->di))
	css_addr =3D 0;
    return 0;
}
static int handler_cssreleased_pre(struct kprobe *p,struct pt_regs =
*regs)
{
   atomic_inc(&cssreleased);
    return 0;
}
static int handler_cssoffline_pre(struct kprobe *p,struct pt_regs *regs)
{
   atomic_inc(&cssoffline);
    return 0;
}

static void handler_post(struct kprobe *p, struct pt_regs *regs,
                unsigned long flags)
{
}

static int handler_fault(struct kprobe *p, struct pt_regs *regs, int =
trapnr)
{
    return 0;
}

static int myleak_read(struct seq_file *m, void *v)
{
        seq_printf(m,"alloc %d  offline %d release %d free %d trace addr =
%px\n",atomic_read(&cssalloc),atomic_read(&cssoffline),
		=
atomic_read(&cssreleased),atomic_read(&cssfree),css_addr);
        return 0;
}

static int myleak_open(struct inode *inode, struct file *file)
{
        return single_open(file, myleak_read, NULL);
}

ssize_t myleak_write(struct file *filp,const char *buf,size_t =
count,loff_t *offp){
	css_addr =3D 0;
	return count;
}

static const struct file_operations myleak =3D {
        .open =3Dmyleak_open,
        .read =3D seq_read,
	.write =3D myleak_write,
        .llseek =3D seq_lseek,
        .release =3D single_release,
};

static int __init kprobe_init(void)
{
    int ret;
    css_alloc.entry_handler =3D handler_cssalloc_pre;
    css_alloc.handler =3D ret_handler_cssalloc_pre;
    css_alloc.maxactive =3D 0;

    css_free.pre_handler =3D handler_cssfree_pre;
    css_free.post_handler =3D handler_post;
    css_free.fault_handler =3D handler_fault;

    css_released.pre_handler =3D handler_cssreleased_pre;
    css_released.post_handler =3D handler_post;
    css_released.fault_handler =3D handler_fault;

    css_offline.pre_handler =3D handler_cssoffline_pre;
    css_offline.post_handler =3D handler_post;
    css_offline.fault_handler =3D handler_fault;

    trycharge.pre_handler =3D handler_trycharge;
    trycharge.post_handler =3D handler_post;
    trycharge.fault_handler =3D handler_fault;

    charge.pre_handler =3D handler_charge;
    charge.post_handler =3D handler_post;
    charge.fault_handler =3D handler_fault;

    uncharge.pre_handler =3D handler_uncharge;
    uncharge.post_handler =3D handler_post;
    uncharge.fault_handler =3D handler_fault;
    atomic_set(&cssalloc,0);
    atomic_set(&cssfree,0);
    atomic_set(&cssreleased,0);
    atomic_set(&cssoffline,0);

    ret =3D register_kretprobe(&css_alloc);
    if (ret < 0) {
        printk(KERN_INFO "register_kprobe failed, returned %d\n", ret);
        return ret;
    }
    ret =3D register_kprobe(&css_free);
    if (ret < 0) {
        printk(KERN_INFO "register_kprobe failed, returned %d\n", ret);
        return ret;
    }
    ret =3D register_kprobe(&css_released);
    if (ret < 0) {
        printk(KERN_INFO "register_kprobe failed, returned %d\n", ret);
        return ret;
    }
    ret =3D register_kprobe(&css_offline);
    if (ret < 0) {
        printk(KERN_INFO "register_kprobe failed, returned %d\n", ret);
        return ret;
    }
    ret =3D register_kprobe(&trycharge);
    if (ret < 0) {
        printk(KERN_INFO "register_kprobe failed, returned %d\n", ret);
        return ret;
    }
    ret =3D register_kprobe(&charge);
    if (ret < 0) {
        printk(KERN_INFO "register_kprobe failed, returned %d\n", ret);
        return ret;
    }
    ret =3D register_kprobe(&uncharge);
    if (ret < 0) {
        printk(KERN_INFO "register_kprobe failed, returned %d\n", ret);
        return ret;
    }
    proc_create("cgroup_leak", 0, NULL, &myleak);
    printk(KERN_INFO "Planted kprobe at %p\n", css_alloc.kp.addr);
    printk(KERN_INFO "Planted kprobe at %p\n", css_free.addr);
    printk(KERN_INFO "Planted kprobe at %p\n", css_released.addr);
    printk(KERN_INFO "Planted kprobe at %p\n", css_offline.addr);
    printk(KERN_INFO "Planted kprobe at %p\n", trycharge.addr);
    printk(KERN_INFO "Planted kprobe at %p\n", charge.addr);
    printk(KERN_INFO "Planted kprobe at %p\n", uncharge.addr);
    return 0;
}

static void __exit kprobe_exit(void)
{
    unregister_kretprobe(&css_alloc);
    unregister_kprobe(&css_free);
    unregister_kprobe(&css_released);
    unregister_kprobe(&css_offline);
    unregister_kprobe(&trycharge);
    unregister_kprobe(&charge);
    unregister_kprobe(&uncharge);
    printk(KERN_INFO "kprobe at %p unregistered\n", css_alloc.kp.addr);
    printk(KERN_INFO "kprobe at %p unregistered\n", css_free.addr);
    printk(KERN_INFO "kprobe at %p unregistered\n", css_released.addr);
    printk(KERN_INFO "kprobe at %p unregistered\n", css_offline.addr);
    printk(KERN_INFO "kprobe at %p unregistered\n", trycharge.addr);
    printk(KERN_INFO "kprobe at %p unregistered\n", charge.addr);
    printk(KERN_INFO "kprobe at %p unregistered\n", uncharge.addr);
    remove_proc_entry("cgroup_leak",NULL);
}

module_init(kprobe_init)
module_exit(kprobe_exit)
MODULE_LICENSE("GPL");




First delete /var/log/test /var/log/test.1

Then run command systemctl start test ,After three second run command =
systemctl stop test=20

Then write a python script open /var/log/test.1
Import time
f=3Dopen("/var/log/test.1=E2=80=9D)
Time.sleep(1000)

Then in other console echo 3 > /proc/sys/vm/drop_caches

after that we find mem_cgroup object  still unreleased=E3=80=82

if we close the python process=EF=BC=8Cthen echo 3 >  =
/proc/sys/vm/drop_caches=E3=80=82
the mem_cgroup was released=E3=80=82

I think because the inode of test.1 is hold by python process =EF=BC=8C =
so drop_caches is no used=E3=80=82

I do not think this is a real bug=E3=80=82 but programer should care =
about   the memory used=E3=80=82 -:)

Thanks for reply
bytedance.net
=E6=AE=B5=E7=86=8A=E6=98=A5
duanxiongchun@bytedance.com




> On Nov 22, 2018, at 3:34 PM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Thu 22-11-18 10:56:04, =E6=AE=B5=E7=86=8A=E6=98=A5 wrote:
>> After long time dig, we find their lots of offline but not release =
memcg object in memory eating lots of memory.
>> Why this memcg not release? Because the inode pagecache use  some =
page which is charged to those memcg,
>=20
> As already explained these objects should be reclaimed under memory
> pressure. If they are not then there is a bug. And Roman has fixed =
some
> of those recently.
>=20
> Which kernel version are you using?
> --=20
> Michal Hocko
> SUSE Labs


--Apple-Mail=_9EAE8606-1E25-4E59-9C13-71579D139C8C
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head><meta http-equiv=3D"Content-Type" content=3D"text/html; =
charset=3Dutf-8"></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; line-break: after-white-space;" class=3D"">I =
had double check on the newest version 4.20-rc3<div class=3D""><br =
class=3D""></div><div class=3D"">I had wrote a small test .</div><div =
class=3D""><br class=3D""></div><div class=3D""><br class=3D""></div><div =
class=3D"">Test service code&nbsp;</div><div class=3D""><br =
class=3D""></div><div class=3D""><div class=3D"">#include =
&lt;sys/types.h&gt;</div><div class=3D"">#include =
&lt;sys/stat.h&gt;</div><div class=3D"">#include =
&lt;fcntl.h&gt;</div><div class=3D"">#include &lt;unistd.h&gt;</div><div =
class=3D"">int main()</div><div class=3D"">{</div><div class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>struct =
stat buf;</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>int fd ;</div><div class=3D""><span=
 class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>fd =3D =
open("/var/log/test",O_RDWR|O_CREAT|O_APPEND|O_CLOEXEC,0644);</div><div =
class=3D""><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>sleep(1);</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>fd =3D open("/var/log/test.1", =
O_RDWR|O_CREAT|O_APPEND|O_CLOEXEC|O_SYNC, 0644);</div><div =
class=3D""><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>char log[4096] =3D {'a'};</div><div class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>if (fd =
&gt; 0) {</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">		</span>write(fd, log, =
4096);</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">		</span>close(fd);</div><div =
class=3D""><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>}</div><div class=3D""><br class=3D""></div><div class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>return =
1;</div><div class=3D"">}</div></div><div class=3D""><br =
class=3D""></div><div class=3D""><br class=3D""></div><div =
class=3D"">Test.service&nbsp;</div><div class=3D""><br =
class=3D""></div><div class=3D""><div class=3D"">[Service]</div><div =
class=3D"">ExecStart=3D/usr/bin/test</div><div =
class=3D"">Restart=3Dalways</div><div =
class=3D"">RestartSec=3D100ms</div><div =
class=3D"">MemoryLimit=3D1G</div><div =
class=3D"">StartLimitInterval=3D0</div><div class=3D"">[Install]</div><div=
 class=3D"">WantedBy=3Ddefault.target</div></div><div class=3D""><br =
class=3D""></div><div class=3D"">Probe code&nbsp;</div><div class=3D""><br=
 class=3D""></div><div class=3D"">Get test.1 node address kretprobe =
&nbsp;code&nbsp;</div><div class=3D""><br class=3D""></div><div =
class=3D""><div class=3D"">#include &lt;linux/kernel.h&gt;</div><div =
class=3D"">#include &lt;linux/module.h&gt;</div><div class=3D"">#include =
&lt;linux/kprobes.h&gt;</div><div class=3D"">#include =
&lt;linux/seq_file.h&gt;</div><div class=3D"">#include =
&lt;linux/proc_fs.h&gt;</div><div class=3D"">#include =
&lt;linux/spinlock.h&gt;</div><div class=3D""><br class=3D""></div><div =
class=3D"">static struct kretprobe kprobe_ret_object =3D {</div><div =
class=3D"">&nbsp; &nbsp; .kp.symbol_name &nbsp; &nbsp;=3D =
"d_lookup",</div><div class=3D"">};</div><div class=3D""><br =
class=3D""></div><div class=3D"">static int handler_d_lookup_pre(struct =
kretprobe_instance *p, struct pt_regs *regs)</div><div =
class=3D"">{</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>int *tmp;</div><div =
class=3D""><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>struct qstr * name =3D(struct qstr *)regs-&gt;si;</div><div =
class=3D""><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>tmp=3D(int *)p-&gt;data;</div><div class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>*tmp=3D0;</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	=
</span>if(strcmp("test.1",name-&gt;name)=3D=3D0)</div><div =
class=3D""><span class=3D"Apple-tab-span" style=3D"white-space:pre">		=
</span>*tmp=3D1;</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>return 0;</div><div =
class=3D"">}</div><div class=3D""><br class=3D""></div><div =
class=3D"">static int ret_handler_d_lookup_pre(struct kretprobe_instance =
*p,struct pt_regs *regs)</div><div class=3D"">{</div><div class=3D""><span=
 class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>int =
*tmp;</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>struct dentry * tmp_dentry =3D =
(struct dentry *)regs_return_value(regs);</div><div class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>tmp =3D =
(int *)p-&gt;data;</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>if(*tmp =3D=3D 1)</div><div =
class=3D""><span class=3D"Apple-tab-span" style=3D"white-space:pre">		=
</span>printk(KERN_INFO "return dentry address %px,inode address =
%px\n",</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">			=
</span>tmp_dentry,tmp_dentry-&gt;d_inode);</div><div class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>return =
0;</div><div class=3D"">}</div><div class=3D"">static int __init =
kprobe_init(void)</div><div class=3D"">{</div><div class=3D"">&nbsp; =
&nbsp; int ret;</div><div class=3D"">&nbsp; &nbsp; =
kprobe_ret_object.entry_handler =3D handler_d_lookup_pre;</div><div =
class=3D"">&nbsp; &nbsp; kprobe_ret_object.handler =3D =
ret_handler_d_lookup_pre;</div><div class=3D"">&nbsp; &nbsp; =
kprobe_ret_object.maxactive =3D 0;</div><div class=3D"">&nbsp; &nbsp; =
kprobe_ret_object.data_size =3D sizeof(int);</div><div class=3D""><br =
class=3D""></div><div class=3D"">&nbsp; &nbsp; ret =3D =
register_kretprobe(&amp;kprobe_ret_object);</div><div class=3D"">&nbsp; =
&nbsp; if (ret &lt; 0) {</div><div class=3D"">&nbsp; &nbsp; &nbsp; =
&nbsp; printk(KERN_INFO "register_kprobe failed, returned %d\n", =
ret);</div><div class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; return =
ret;</div><div class=3D"">&nbsp; &nbsp; }</div><div class=3D"">&nbsp; =
&nbsp; printk(KERN_INFO "Planted kprobe at %p\n", =
kprobe_ret_object.kp.addr);</div><div class=3D"">&nbsp; &nbsp; return =
0;</div><div class=3D"">}</div><div class=3D""><br class=3D""></div><div =
class=3D"">static void __exit kprobe_exit(void)</div><div =
class=3D"">{</div><div class=3D"">&nbsp; &nbsp; =
unregister_kretprobe(&amp;kprobe_ret_object);</div><div class=3D"">&nbsp; =
&nbsp; printk(KERN_INFO "kprobe at %p unregistered\n", =
kprobe_ret_object.kp.addr);</div><div class=3D"">}</div><div =
class=3D""><br class=3D""></div><div =
class=3D"">module_init(kprobe_init)</div><div =
class=3D"">module_exit(kprobe_exit)</div><div =
class=3D"">MODULE_LICENSE("GPL=E2=80=9D);</div></div><div class=3D""><br =
class=3D""></div><div class=3D"">Get unreleased mem_cgroup =
address</div><div class=3D""><br class=3D""></div><div class=3D""><div =
class=3D"">#include &lt;linux/kernel.h&gt;</div><div class=3D"">#include =
&lt;linux/module.h&gt;</div><div class=3D"">#include =
&lt;linux/kprobes.h&gt;</div><div class=3D"">#include =
&lt;linux/seq_file.h&gt;</div><div class=3D"">#include =
&lt;linux/proc_fs.h&gt;</div><div class=3D"">#include =
&lt;linux/spinlock.h&gt;</div><div class=3D""><br class=3D""></div><div =
class=3D"">static struct kretprobe css_alloc =3D {</div><div =
class=3D"">&nbsp; &nbsp; .kp.symbol_name &nbsp; &nbsp;=3D =
"mem_cgroup_css_alloc",</div><div class=3D"">};</div><div class=3D""><br =
class=3D""></div><div class=3D"">static struct kprobe css_free =3D =
{</div><div class=3D"">&nbsp; &nbsp; .symbol_name &nbsp; &nbsp;=3D =
"mem_cgroup_css_free",</div><div class=3D"">};</div><div class=3D"">static=
 struct kprobe css_released =3D {</div><div class=3D"">&nbsp; &nbsp; =
.symbol_name &nbsp; &nbsp;=3D "mem_cgroup_css_released",</div><div =
class=3D"">};</div><div class=3D"">static struct kprobe css_offline =3D =
{</div><div class=3D"">&nbsp; &nbsp; .symbol_name &nbsp; &nbsp;=3D =
"mem_cgroup_css_offline",</div><div class=3D"">};</div><div =
class=3D"">static struct kprobe trycharge =3D {</div><div =
class=3D"">&nbsp; &nbsp; .symbol_name &nbsp; &nbsp;=3D =
"page_counter_try_charge",</div><div class=3D"">};</div><div =
class=3D"">static struct kprobe charge =3D {</div><div class=3D"">&nbsp; =
&nbsp; .symbol_name &nbsp; &nbsp;=3D "page_counter_charge",</div><div =
class=3D"">};</div><div class=3D"">static struct kprobe uncharge =3D =
{</div><div class=3D"">&nbsp; &nbsp; .symbol_name &nbsp; &nbsp;=3D =
"page_counter_uncharge",</div><div class=3D"">};</div><div class=3D""><br =
class=3D""></div><div class=3D"">atomic_t cssalloc;</div><div =
class=3D"">atomic_t cssfree;</div><div class=3D"">atomic_t =
cssreleased;</div><div class=3D"">atomic_t cssoffline;</div><div =
class=3D"">static spinlock_t my_lock =3D =
__SPIN_LOCK_UNLOCKED();</div><div class=3D"">void * =
css_addr=3D0;</div><div class=3D"">void * memory_addr=3D0;</div><div =
class=3D""><br class=3D""></div><div class=3D"">static int =
handler_trycharge(struct kprobe *p,struct pt_regs *regs)</div><div =
class=3D"">{</div><div class=3D"">&nbsp; &nbsp; if (memory_addr =3D=3D =
(void *)(regs-&gt;di)){</div><div class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>printk(KERN_INFO"trycharge_memory %px nr %px",(void =
*)memory_addr,(void *)regs-&gt;si);</div><div class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>spin_lock(&amp;my_lock);</div><div class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>dump_stack();</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	=
</span>spin_unlock(&amp;my_lock);</div><div class=3D"">&nbsp; &nbsp; =
}</div><div class=3D"">&nbsp; &nbsp; return 0;</div><div =
class=3D"">}</div><div class=3D"">static int handler_charge(struct =
kprobe *p,struct pt_regs *regs)</div><div class=3D"">{</div><div =
class=3D"">&nbsp; &nbsp; if (memory_addr =3D=3D (void =
*)(regs-&gt;di)){</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>printk(KERN_INFO"charge_memory =
%px,nr %px",(void *)memory_addr,(void *)regs-&gt;si);</div><div =
class=3D""><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>spin_lock(&amp;my_lock);</div><div class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>dump_stack();</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	=
</span>spin_unlock(&amp;my_lock);</div><div class=3D"">&nbsp; &nbsp; =
}</div><div class=3D"">&nbsp; &nbsp; return 0;</div><div =
class=3D"">}</div><div class=3D"">static int handler_uncharge(struct =
kprobe *p,struct pt_regs *regs)</div><div class=3D"">{</div><div =
class=3D"">&nbsp; &nbsp; if (memory_addr =3D=3D (void =
*)(regs-&gt;di)){</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>printk(KERN_INFO"uncharge_memory =
%px,nr %px",(void *)memory_addr,(void *)regs-&gt;si);</div><div =
class=3D""><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>spin_lock(&amp;my_lock);</div><div class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>dump_stack();</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	=
</span>spin_unlock(&amp;my_lock);</div><div class=3D"">&nbsp; &nbsp; =
}</div><div class=3D"">&nbsp; &nbsp; return 0;</div><div =
class=3D"">}</div><div class=3D""><br class=3D""></div><div =
class=3D"">static int handler_cssalloc_pre(struct kretprobe_instance *p, =
struct pt_regs *regs)</div><div class=3D"">{</div><div class=3D"">&nbsp; =
&nbsp; atomic_inc(&amp;cssalloc);</div><div class=3D"">&nbsp; &nbsp; =
return 0;</div><div class=3D"">}</div><div class=3D""><br =
class=3D""></div><div class=3D"">static int =
ret_handler_cssalloc_pre(struct kretprobe_instance *p,struct pt_regs =
*regs)</div><div class=3D"">{</div><div class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>if =
(css_addr=3D=3D0){</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">		</span>css_addr=3D(void =
*)regs_return_value(regs);</div><div class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">		=
</span>memory_addr=3D(void *)(regs_return_value(regs)+192);</div><div =
class=3D""><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>}</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>return 0;</div><div =
class=3D"">}</div><div class=3D""><br class=3D""></div><div =
class=3D"">static int handler_cssfree_pre(struct kprobe *p,struct =
pt_regs *regs)</div><div class=3D"">{</div><div class=3D"">&nbsp; =
&nbsp;atomic_inc(&amp;cssfree);</div><div class=3D"">&nbsp; &nbsp; if =
(css_addr =3D=3D (void *)(regs-&gt;di))</div><div class=3D""><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span>css_addr =
=3D 0;</div><div class=3D"">&nbsp; &nbsp; return 0;</div><div =
class=3D"">}</div><div class=3D"">static int =
handler_cssreleased_pre(struct kprobe *p,struct pt_regs *regs)</div><div =
class=3D"">{</div><div class=3D"">&nbsp; =
&nbsp;atomic_inc(&amp;cssreleased);</div><div class=3D"">&nbsp; &nbsp; =
return 0;</div><div class=3D"">}</div><div class=3D"">static int =
handler_cssoffline_pre(struct kprobe *p,struct pt_regs *regs)</div><div =
class=3D"">{</div><div class=3D"">&nbsp; =
&nbsp;atomic_inc(&amp;cssoffline);</div><div class=3D"">&nbsp; &nbsp; =
return 0;</div><div class=3D"">}</div><div class=3D""><br =
class=3D""></div><div class=3D"">static void handler_post(struct kprobe =
*p, struct pt_regs *regs,</div><div class=3D"">&nbsp; &nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; unsigned long flags)</div><div =
class=3D"">{</div><div class=3D"">}</div><div class=3D""><br =
class=3D""></div><div class=3D"">static int handler_fault(struct kprobe =
*p, struct pt_regs *regs, int trapnr)</div><div class=3D"">{</div><div =
class=3D"">&nbsp; &nbsp; return 0;</div><div class=3D"">}</div><div =
class=3D""><br class=3D""></div><div class=3D"">static int =
myleak_read(struct seq_file *m, void *v)</div><div class=3D"">{</div><div =
class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; seq_printf(m,"alloc %d =
&nbsp;offline %d release %d free %d trace addr =
%px\n",atomic_read(&amp;cssalloc),atomic_read(&amp;cssoffline),</div><div =
class=3D""><span class=3D"Apple-tab-span" style=3D"white-space:pre">		=
</span>atomic_read(&amp;cssreleased),atomic_read(&amp;cssfree),css_addr);<=
/div><div class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; return 0;</div><div =
class=3D"">}</div><div class=3D""><br class=3D""></div><div =
class=3D"">static int myleak_open(struct inode *inode, struct file =
*file)</div><div class=3D"">{</div><div class=3D"">&nbsp; &nbsp; &nbsp; =
&nbsp; return single_open(file, myleak_read, NULL);</div><div =
class=3D"">}</div><div class=3D""><br class=3D""></div><div =
class=3D"">ssize_t myleak_write(struct file *filp,const char *buf,size_t =
count,loff_t *offp){</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>css_addr =3D 0;</div><div =
class=3D""><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>return count;</div><div class=3D"">}</div><div class=3D""><br =
class=3D""></div><div class=3D"">static const struct file_operations =
myleak =3D {</div><div class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; .open =
=3Dmyleak_open,</div><div class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; .read =3D=
 seq_read,</div><div class=3D""><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>.write =3D =
myleak_write,</div><div class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; .llseek =3D=
 seq_lseek,</div><div class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; .release =3D =
single_release,</div><div class=3D"">};</div><div class=3D""><br =
class=3D""></div><div class=3D"">static int __init =
kprobe_init(void)</div><div class=3D"">{</div><div class=3D"">&nbsp; =
&nbsp; int ret;</div><div class=3D"">&nbsp; &nbsp; =
css_alloc.entry_handler =3D handler_cssalloc_pre;</div><div =
class=3D"">&nbsp; &nbsp; css_alloc.handler =3D =
ret_handler_cssalloc_pre;</div><div class=3D"">&nbsp; &nbsp; =
css_alloc.maxactive =3D 0;</div><div class=3D""><br class=3D""></div><div =
class=3D"">&nbsp; &nbsp; css_free.pre_handler =3D =
handler_cssfree_pre;</div><div class=3D"">&nbsp; &nbsp; =
css_free.post_handler =3D handler_post;</div><div class=3D"">&nbsp; =
&nbsp; css_free.fault_handler =3D handler_fault;</div><div class=3D""><br =
class=3D""></div><div class=3D"">&nbsp; &nbsp; css_released.pre_handler =
=3D handler_cssreleased_pre;</div><div class=3D"">&nbsp; &nbsp; =
css_released.post_handler =3D handler_post;</div><div class=3D"">&nbsp; =
&nbsp; css_released.fault_handler =3D handler_fault;</div><div =
class=3D""><br class=3D""></div><div class=3D"">&nbsp; &nbsp; =
css_offline.pre_handler =3D handler_cssoffline_pre;</div><div =
class=3D"">&nbsp; &nbsp; css_offline.post_handler =3D =
handler_post;</div><div class=3D"">&nbsp; &nbsp; =
css_offline.fault_handler =3D handler_fault;</div><div class=3D""><br =
class=3D""></div><div class=3D"">&nbsp; &nbsp; trycharge.pre_handler =3D =
handler_trycharge;</div><div class=3D"">&nbsp; &nbsp; =
trycharge.post_handler =3D handler_post;</div><div class=3D"">&nbsp; =
&nbsp; trycharge.fault_handler =3D handler_fault;</div><div class=3D""><br=
 class=3D""></div><div class=3D"">&nbsp; &nbsp; charge.pre_handler =3D =
handler_charge;</div><div class=3D"">&nbsp; &nbsp; charge.post_handler =3D=
 handler_post;</div><div class=3D"">&nbsp; &nbsp; charge.fault_handler =3D=
 handler_fault;</div><div class=3D""><br class=3D""></div><div =
class=3D"">&nbsp; &nbsp; uncharge.pre_handler =3D =
handler_uncharge;</div><div class=3D"">&nbsp; &nbsp; =
uncharge.post_handler =3D handler_post;</div><div class=3D"">&nbsp; =
&nbsp; uncharge.fault_handler =3D handler_fault;</div><div =
class=3D"">&nbsp; &nbsp; atomic_set(&amp;cssalloc,0);</div><div =
class=3D"">&nbsp; &nbsp; atomic_set(&amp;cssfree,0);</div><div =
class=3D"">&nbsp; &nbsp; atomic_set(&amp;cssreleased,0);</div><div =
class=3D"">&nbsp; &nbsp; atomic_set(&amp;cssoffline,0);</div><div =
class=3D""><br class=3D""></div><div class=3D"">&nbsp; &nbsp; ret =3D =
register_kretprobe(&amp;css_alloc);</div><div class=3D"">&nbsp; &nbsp; =
if (ret &lt; 0) {</div><div class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; =
printk(KERN_INFO "register_kprobe failed, returned %d\n", =
ret);</div><div class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; return =
ret;</div><div class=3D"">&nbsp; &nbsp; }</div><div class=3D"">&nbsp; =
&nbsp; ret =3D register_kprobe(&amp;css_free);</div><div class=3D"">&nbsp;=
 &nbsp; if (ret &lt; 0) {</div><div class=3D"">&nbsp; &nbsp; &nbsp; =
&nbsp; printk(KERN_INFO "register_kprobe failed, returned %d\n", =
ret);</div><div class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; return =
ret;</div><div class=3D"">&nbsp; &nbsp; }</div><div class=3D"">&nbsp; =
&nbsp; ret =3D register_kprobe(&amp;css_released);</div><div =
class=3D"">&nbsp; &nbsp; if (ret &lt; 0) {</div><div class=3D"">&nbsp; =
&nbsp; &nbsp; &nbsp; printk(KERN_INFO "register_kprobe failed, returned =
%d\n", ret);</div><div class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; return =
ret;</div><div class=3D"">&nbsp; &nbsp; }</div><div class=3D"">&nbsp; =
&nbsp; ret =3D register_kprobe(&amp;css_offline);</div><div =
class=3D"">&nbsp; &nbsp; if (ret &lt; 0) {</div><div class=3D"">&nbsp; =
&nbsp; &nbsp; &nbsp; printk(KERN_INFO "register_kprobe failed, returned =
%d\n", ret);</div><div class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; return =
ret;</div><div class=3D"">&nbsp; &nbsp; }</div><div class=3D"">&nbsp; =
&nbsp; ret =3D register_kprobe(&amp;trycharge);</div><div =
class=3D"">&nbsp; &nbsp; if (ret &lt; 0) {</div><div class=3D"">&nbsp; =
&nbsp; &nbsp; &nbsp; printk(KERN_INFO "register_kprobe failed, returned =
%d\n", ret);</div><div class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; return =
ret;</div><div class=3D"">&nbsp; &nbsp; }</div><div class=3D"">&nbsp; =
&nbsp; ret =3D register_kprobe(&amp;charge);</div><div class=3D"">&nbsp; =
&nbsp; if (ret &lt; 0) {</div><div class=3D"">&nbsp; &nbsp; &nbsp; =
&nbsp; printk(KERN_INFO "register_kprobe failed, returned %d\n", =
ret);</div><div class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; return =
ret;</div><div class=3D"">&nbsp; &nbsp; }</div><div class=3D"">&nbsp; =
&nbsp; ret =3D register_kprobe(&amp;uncharge);</div><div class=3D"">&nbsp;=
 &nbsp; if (ret &lt; 0) {</div><div class=3D"">&nbsp; &nbsp; &nbsp; =
&nbsp; printk(KERN_INFO "register_kprobe failed, returned %d\n", =
ret);</div><div class=3D"">&nbsp; &nbsp; &nbsp; &nbsp; return =
ret;</div><div class=3D"">&nbsp; &nbsp; }</div><div class=3D"">&nbsp; =
&nbsp; proc_create("cgroup_leak", 0, NULL, &amp;myleak);</div><div =
class=3D"">&nbsp; &nbsp; printk(KERN_INFO "Planted kprobe at %p\n", =
css_alloc.kp.addr);</div><div class=3D"">&nbsp; &nbsp; printk(KERN_INFO =
"Planted kprobe at %p\n", css_free.addr);</div><div class=3D"">&nbsp; =
&nbsp; printk(KERN_INFO "Planted kprobe at %p\n", =
css_released.addr);</div><div class=3D"">&nbsp; &nbsp; printk(KERN_INFO =
"Planted kprobe at %p\n", css_offline.addr);</div><div class=3D"">&nbsp; =
&nbsp; printk(KERN_INFO "Planted kprobe at %p\n", =
trycharge.addr);</div><div class=3D"">&nbsp; &nbsp; printk(KERN_INFO =
"Planted kprobe at %p\n", charge.addr);</div><div class=3D"">&nbsp; =
&nbsp; printk(KERN_INFO "Planted kprobe at %p\n", =
uncharge.addr);</div><div class=3D"">&nbsp; &nbsp; return 0;</div><div =
class=3D"">}</div><div class=3D""><br class=3D""></div><div =
class=3D"">static void __exit kprobe_exit(void)</div><div =
class=3D"">{</div><div class=3D"">&nbsp; &nbsp; =
unregister_kretprobe(&amp;css_alloc);</div><div class=3D"">&nbsp; &nbsp; =
unregister_kprobe(&amp;css_free);</div><div class=3D"">&nbsp; &nbsp; =
unregister_kprobe(&amp;css_released);</div><div class=3D"">&nbsp; &nbsp; =
unregister_kprobe(&amp;css_offline);</div><div class=3D"">&nbsp; &nbsp; =
unregister_kprobe(&amp;trycharge);</div><div class=3D"">&nbsp; &nbsp; =
unregister_kprobe(&amp;charge);</div><div class=3D"">&nbsp; &nbsp; =
unregister_kprobe(&amp;uncharge);</div><div class=3D"">&nbsp; &nbsp; =
printk(KERN_INFO "kprobe at %p unregistered\n", =
css_alloc.kp.addr);</div><div class=3D"">&nbsp; &nbsp; printk(KERN_INFO =
"kprobe at %p unregistered\n", css_free.addr);</div><div class=3D"">&nbsp;=
 &nbsp; printk(KERN_INFO "kprobe at %p unregistered\n", =
css_released.addr);</div><div class=3D"">&nbsp; &nbsp; printk(KERN_INFO =
"kprobe at %p unregistered\n", css_offline.addr);</div><div =
class=3D"">&nbsp; &nbsp; printk(KERN_INFO "kprobe at %p unregistered\n", =
trycharge.addr);</div><div class=3D"">&nbsp; &nbsp; printk(KERN_INFO =
"kprobe at %p unregistered\n", charge.addr);</div><div class=3D"">&nbsp; =
&nbsp; printk(KERN_INFO "kprobe at %p unregistered\n", =
uncharge.addr);</div><div class=3D"">&nbsp; &nbsp; =
remove_proc_entry("cgroup_leak",NULL);</div><div class=3D"">}</div><div =
class=3D""><br class=3D""></div><div =
class=3D"">module_init(kprobe_init)</div><div =
class=3D"">module_exit(kprobe_exit)</div><div =
class=3D"">MODULE_LICENSE("GPL");</div></div><div class=3D""><br =
class=3D""></div><div class=3D""><br class=3D""></div><div class=3D""><br =
class=3D""></div><div class=3D""><br class=3D""></div><div =
class=3D"">First delete /var/log/test /var/log/test.1</div><div =
class=3D""><br class=3D""></div><div class=3D"">Then run command =
systemctl start test ,After three second run command systemctl stop =
test&nbsp;</div><div class=3D""><br class=3D""></div><div class=3D"">Then =
write a python script open /var/log/test.1</div><div class=3D"">Import =
time</div><div class=3D"">f=3Dopen("/var/log/test.1=E2=80=9D)</div><div =
class=3D"">Time.sleep(1000)</div><div class=3D""><br class=3D""></div><div=
 class=3D"">Then in other console echo 3 &gt; =
/proc/sys/vm/drop_caches</div><div class=3D""><br class=3D""></div><div =
class=3D"">after that we find mem_cgroup object &nbsp;still =
unreleased=E3=80=82</div><div class=3D""><br class=3D""></div><div =
class=3D"">if we close the python process=EF=BC=8Cthen echo 3 &gt; =
&nbsp;/proc/sys/vm/drop_caches=E3=80=82</div><div class=3D"">the =
mem_cgroup was released=E3=80=82</div><div class=3D""><br =
class=3D""></div><div class=3D"">I think because the inode of test.1 is =
hold by python process =EF=BC=8C so drop_caches is no used=E3=80=82</div><=
div class=3D""><br class=3D""></div><div class=3D"">I do not think this =
is a real bug=E3=80=82 but programer should care about &nbsp; the memory =
used=E3=80=82 -:)</div><div class=3D""><br class=3D""></div><div =
class=3D"">Thanks for reply</div><div class=3D""><div class=3D"">
<div dir=3D"auto" style=3D"word-wrap: break-word; -webkit-nbsp-mode: =
space; line-break: after-white-space;" class=3D""><div =
style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0); font-family: =
Helvetica; font-size: 12px; font-style: normal; font-variant-caps: =
normal; font-weight: normal; letter-spacing: normal; text-align: start; =
text-indent: 0px; text-transform: none; white-space: normal; =
word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration: =
none;"><a href=3D"http://bytedance.net" class=3D"">bytedance.net</a><br =
class=3D"">=E6=AE=B5=E7=86=8A=E6=98=A5<br =
class=3D"">duanxiongchun@bytedance.com<br class=3D""><br =
class=3D""></div><br class=3D"Apple-interchange-newline"></div><br =
class=3D"Apple-interchange-newline">
</div>
<div><br class=3D""><blockquote type=3D"cite" class=3D""><div =
class=3D"">On Nov 22, 2018, at 3:34 PM, Michal Hocko &lt;<a =
href=3D"mailto:mhocko@kernel.org" class=3D"">mhocko@kernel.org</a>&gt; =
wrote:</div><br class=3D"Apple-interchange-newline"><div class=3D""><div =
class=3D"">On Thu 22-11-18 10:56:04, =E6=AE=B5=E7=86=8A=E6=98=A5 =
wrote:<br class=3D""><blockquote type=3D"cite" class=3D"">After long =
time dig, we find their lots of offline but not release memcg object in =
memory eating lots of memory.<br class=3D"">Why this memcg not release? =
Because the inode pagecache use &nbsp;some page which is charged to =
those memcg,<br class=3D""></blockquote><br class=3D"">As already =
explained these objects should be reclaimed under memory<br =
class=3D"">pressure. If they are not then there is a bug. And Roman has =
fixed some<br class=3D"">of those recently.<br class=3D""><br =
class=3D"">Which kernel version are you using?<br class=3D"">-- <br =
class=3D"">Michal Hocko<br class=3D"">SUSE Labs<br =
class=3D""></div></div></blockquote></div><br =
class=3D""></div></body></html>=

--Apple-Mail=_9EAE8606-1E25-4E59-9C13-71579D139C8C--
