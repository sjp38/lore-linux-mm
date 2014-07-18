Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f170.google.com (mail-vc0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id E37256B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 14:47:09 -0400 (EDT)
Received: by mail-vc0-f170.google.com with SMTP id lf12so8007508vcb.29
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 11:47:09 -0700 (PDT)
Received: from mail-vc0-x236.google.com (mail-vc0-x236.google.com [2607:f8b0:400c:c03::236])
        by mx.google.com with ESMTPS id hq3si5684159veb.59.2014.07.18.11.47.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 11:47:09 -0700 (PDT)
Received: by mail-vc0-f182.google.com with SMTP id hy4so8338702vcb.27
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 11:47:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140718181947.GE13012@htj.dyndns.org>
References: <20140717230923.GA32660@linux.vnet.ibm.com>
	<20140718112039.GA8383@htj.dyndns.org>
	<CAOhV88PyBK3WxDjG1H0hUbRhRYzPOzV8eim5DuOcgObe-FtFYg@mail.gmail.com>
	<20140718180008.GC13012@htj.dyndns.org>
	<CAOhV88O03zCsv_3eadEKNv1D1RoBmjWRFNhPjEHawF9s71U0JA@mail.gmail.com>
	<20140718181947.GE13012@htj.dyndns.org>
Date: Fri, 18 Jul 2014 11:47:08 -0700
Message-ID: <CAOhV88Mby_vrLPtRsRNO724-_ABEL06Fc1mMwjgq7LWw-uxeAw@mail.gmail.com>
Subject: Re: [RFC 0/2] Memoryless nodes and kworker
From: Nish Aravamudan <nish.aravamudan@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c22fb441517f04fe7c2f4f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

--001a11c22fb441517f04fe7c2f4f
Content-Type: text/plain; charset=UTF-8

On Fri, Jul 18, 2014 at 11:19 AM, Tejun Heo <tj@kernel.org> wrote:
>
> Hello,
>
> On Fri, Jul 18, 2014 at 11:12:01AM -0700, Nish Aravamudan wrote:
> > why aren't these callers using kthread_create_on_cpu()? That API was
>
> It is using that.  There just are other data structures too.

Sorry, I might not have been clear.

Why are any callers of the format kthread_create_on_node(...,
cpu_to_node(cpu), ...) not using kthread_create_on_cpu(..., cpu, ...)?

In total in Linus' tree, there are only two APIs that use
kthread_create_on_cpu() -- smpboot_create_threads() and
smpboot_register_percpu_thread(). Neither of those seem to be used by the
workqueue code that I can see as of yet.

> > already change to use cpu_to_mem() [so one change, rather than of all
over
> > the kernel source]. We could change it back to cpu_to_node and push down
> > the knowledge about the fallback.
>
> And once it's properly solved, please convert back kthread to use
> cpu_to_node() too.  We really shouldn't be sprinkling the new subtly
> different variant across the kernel.  It's wrong and confusing.

I understand what you mean, but it's equally wrong for the kernel to be
wasting GBs of slab. Different kinds of wrongness :)

> > Yes, this is a good point. But honestly, we're not really even to the
point
> > of talking about fallback here, at least in my testing, going off-node
at
> > all causes SLUB-configured slabs to deactivate, which then leads to an
> > explosion in the unreclaimable slab.
>
> I don't think moving the logic inside allocator proper is a huge
> amount of work and this isn't the first spillage of this subtlety out
> of allocator proper.  Fortunately, it hasn't spread too much yet.
> Let's please stop it here.  I'm not saying you shouldn't or can't fix
> the off-node allocation.

It seems like an additional reasonable approach would be to provide a
suitable _cpu() API for the allocators. I'm not sure why saying that
callers should know about NUMA (in order to call cpu_to_node() in every
caller) is any better than saying that callers should know about memoryless
nodes (in order to call cpu_to_mem() in every caller instead) -- when at
least in several cases that I've seen the relevant data is what CPU we're
expecting to run or are running on. Seems like the _cpu API would specify
-- please allocate memory local to this CPU, wherever it is?

Thanks,
Nish

--001a11c22fb441517f04fe7c2f4f
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><div>On Fri, Jul 18, 2014 at 11:19 AM, Tejun Heo &lt;=
<a href=3D"mailto:tj@kernel.org">tj@kernel.org</a>&gt; wrote:<br>&gt;<br>&g=
t; Hello,<br>&gt;<br>&gt; On Fri, Jul 18, 2014 at 11:12:01AM -0700, Nish Ar=
avamudan wrote:<br>
&gt; &gt; why aren&#39;t these callers using kthread_create_on_cpu()? That =
API was<br>&gt;<br>&gt; It is using that. =C2=A0There just are other data s=
tructures too.<br><br></div>Sorry, I might not have been clear.<br><br>Why =
are any callers of the format kthread_create_on_node(..., cpu_to_node(cpu),=
 ...) not using kthread_create_on_cpu(..., cpu, ...)?<br>
<br></div>In total in Linus&#39; tree, there are only two APIs that use kth=
read_create_on_cpu() -- smpboot_create_threads() and smpboot_register_percp=
u_thread(). Neither of those seem to be used by the workqueue code that I c=
an see as of yet.<br>
<div><div><div><br>&gt; &gt; already change to use cpu_to_mem() [so one cha=
nge, rather than of all over<br>&gt; &gt; the kernel source]. We could chan=
ge it back to cpu_to_node and push down<br>&gt; &gt; the knowledge about th=
e fallback.<br>
&gt;<br>&gt; And once it&#39;s properly solved, please convert back kthread=
 to use<br>&gt; cpu_to_node() too. =C2=A0We really shouldn&#39;t be sprinkl=
ing the new subtly<br>&gt; different variant across the kernel. =C2=A0It&#3=
9;s wrong and confusing.<br>
<br></div><div>I understand what you mean, but it&#39;s equally wrong for t=
he kernel to be wasting GBs of slab. Different kinds of wrongness :)<br></d=
iv><div><br>&gt; &gt; Yes, this is a good point. But honestly, we&#39;re no=
t really even to the point<br>
&gt; &gt; of talking about fallback here, at least in my testing, going off=
-node at<br>&gt; &gt; all causes SLUB-configured slabs to deactivate, which=
 then leads to an<br>&gt; &gt; explosion in the unreclaimable slab.<br>
&gt;<br>&gt; I don&#39;t think moving the logic inside allocator proper is =
a huge<br>&gt; amount of work and this isn&#39;t the first spillage of this=
 subtlety out<br>&gt; of allocator proper. =C2=A0Fortunately, it hasn&#39;t=
 spread too much yet.<br>
&gt; Let&#39;s please stop it here. =C2=A0I&#39;m not saying you shouldn&#3=
9;t or can&#39;t fix<br>&gt; the off-node allocation.<br><br></div><div>It =
seems like an additional reasonable approach would be to provide a suitable=
 _cpu() API for the allocators. I&#39;m not sure why saying that callers sh=
ould know about NUMA (in order to call cpu_to_node() in every caller) is an=
y better than saying that callers should know about memoryless nodes (in or=
der to call cpu_to_mem() in every caller instead) -- when at least in sever=
al cases that I&#39;ve seen the relevant data is what CPU we&#39;re expecti=
ng to run or are running on. Seems like the _cpu API would specify -- pleas=
e allocate memory local to this CPU, wherever it is?<br>
<br></div><div>Thanks,<br></div><div>Nish<br></div></div></div></div>

--001a11c22fb441517f04fe7c2f4f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
