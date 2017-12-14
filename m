Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA2876B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 02:05:41 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id t47so2558802otd.19
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 23:05:41 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 2sor1374505otb.235.2017.12.13.23.05.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 23:05:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171214041650.GB17710@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com> <CAF7GXvqSZzNHdefQWhEb2SDYWX5hDWqQX7cayuVEQ8YyTULPog@mail.gmail.com>
 <20171213161247.GA2927@redhat.com> <CAF7GXvrxo2xj==wA_=fXr+9nF0k0Ed123kZXeKWKBHS6TKYNdA@mail.gmail.com>
 <20171214031607.GA17710@redhat.com> <CAF7GXvqoYXDJNYcrzJo5bGvfBG9iFq8PbeA7RO7y+9DuM7N0og@mail.gmail.com>
 <20171214041650.GB17710@redhat.com>
From: "Figo.zhang" <figo1802@gmail.com>
Date: Thu, 14 Dec 2017 15:05:39 +0800
Message-ID: <CAF7GXvpuvrfRHBBrQ4ADz+ma_=z6T0+9j3As-GBTtS+gNqfZXA@mail.gmail.com>
Subject: Re: [HMM-v25 00/19] HMM (Heterogeneous Memory Management) v25
Content-Type: multipart/alternative; boundary="94eb2c1c0370fed6d405604782f2"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>

--94eb2c1c0370fed6d405604782f2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

2017-12-14 12:16 GMT+08:00 Jerome Glisse <jglisse@redhat.com>:

> On Thu, Dec 14, 2017 at 11:53:40AM +0800, Figo.zhang wrote:
> > 2017-12-14 11:16 GMT+08:00 Jerome Glisse <jglisse@redhat.com>:
> >
> > > On Thu, Dec 14, 2017 at 10:48:36AM +0800, Figo.zhang wrote:
> > > > 2017-12-14 0:12 GMT+08:00 Jerome Glisse <jglisse@redhat.com>:
> > > >
> > > > > On Wed, Dec 13, 2017 at 08:10:42PM +0800, Figo.zhang wrote:
>
> [...]
>
> > > This is not what happen. Here is the workflow with HMM mirror (note
> that
> > > physical address do not matter here so i do not even reference them i=
t
> is
> > > all about virtual address):
> > >  1 They are 3 buffers a, b and r at given virtual address both CPU an=
d
> > >    GPU can access them (concurently or not this does not matter).
> > >  2 GPU can fault so if any virtual address do not have a page table
> > >    entry inside the GPU page table this trigger a page fault that wil=
l
> > >    call HMM mirror helper to snapshot CPU page table into the GPU pag=
e
> > >    table. If there is no physical memory backing the virtual address
> > >    (ie CPU page table is also empty for the given virtual address) th=
en
> > >    the regular page fault handler of the kernel is invoked.
> > >
> >
> > so when HMM mirror done, the content of GPU page table entry and
> > CPU page table entry
> > are same, right? so the GPU and CPU can access the same physical addres=
s,
> > this physical
> > address is allocated by CPU malloc systemcall. is it conflict and race
> > condition? CPU and GPU
> > write to this physical address concurrently.
>
> Correct and yes it is conflict free. PCIE platform already support
> cache coherent access by device to main memory (snoop transaction
> in PCIE specification). Access can happen concurently to same byte
> and it behave exactly the same as if two CPU core try to access the
> same byte.
>
> >
> > i see this slides said:
> > http://on-demand.gputechconf.com/gtc/2017/presentation/
> s7764_john-hubbardgpus-using-hmm-blur-the-lines-between-cpu-and-gpu.pdf
> >
> > in page 22~23=EF=BC=9A
> > When CPU page fault occurs:
> > * UM (unified memory driver) copies page data to CPU, umaps from GPU
> > *HMM maps page to CPU
> >
> > when GPU page fault occurs:
> > *HMM has a malloc record buffer, so UM copy page data to GPU
> > *HMM unmaps page from CPU
> >
> > so in this slides, it said it will has two copies, from CPU to GPU, and
> > from GPU to CPU. so in this case (mul_mat_on_gpu()), is it really need
> two
> > copies in kernel space?
>
> This slide is for the case where you use device memory on PCIE platform.
> When that happen only the device can access the virtual address back by
> device memory. If CPU try to access such address a page fault is trigger
> and it migrate the data back to regular memory where both GPU and CPU can
> access it concurently.
>
> And again this behavior only happen if you use HMM non cache coherent
> device memory model. If you use the device cache coherent model with HMM
> then CPU can access the device memory directly too and above scenario
> never happen.
>
> Note that memory copy when data move from device to system or from system
> to device memory are inevitable. This is exactly as with autoNUMA. Also
> note that in some case thing can get allocated directly on GPU and never
> copied back to regular memory (only use by GPU and freed once GPU is done
> with them) the zero copy case. But i want to stress that the zero copy
> case is unlikely to happen for input buffer. Usualy you do not get your
> input data set directly on the GPU but from network or disk and you might
> do pre-processing on CPU (uncompress input, or do something that is bette=
r
> done on the CPU). Then you feed your data to the GPU and you do computati=
on
> there.
>

Great=EF=BC=81very detail about the HMM explanation, Thanks a lot.
so would you like see my conclusion is correct?
* if support CCIX/CAPI, CPU can access GPU memory directly, and GPU also
can access CPU memory directly,
so it no need copy on kernel space in HMM solutions.

* if no support CCIX/CAPI, CPU cannot access GPU memory in cache
coherency method, also GPU cannot access CPU memory at
cache coherency. it need some copies like John Hobburt's slides.
   *when GPU page fault, need copy data from CPU page to GPU page, and
HMM unmap the CPU page...
   * when CPU page fault, need copy data from GPU page to CPU page
and ummap GPU page and map the CPU page...


>
>
> > > Without HMM mirror but ATS/PASI (CCIX or CAPI):
> > >  1 They are 3 buffers a, b and r at given virtual address both CPU an=
d
> > >    GPU can access them (concurently or not this does not matter).
> > >  2 GPU use the exact same page table as the CPU and fault exactly lik=
e
> > >    CPU on empty page table entry
> > >
> > > So in the end with HMM mirror or ATS/PASID you get the same behavior.
> > > There is no complexity like you seem to assume. This all about virtua=
l
> > > address. At any point in time any given valid virtual address of a
> process
> > > point to a given physical memory address and that physical memory
> address
> > > is the same on both the CPU and the GPU at any point in time they are
> > > never out of sync (both in HMM mirror and in ATS/PASID case).
> > >
> > > The exception is for platform that do not have CAPI or CCIX property =
ie
> > > cache coherency for CPU access to device memory. On such platform whe=
n
> > > you migrate a virtual address to use device physical memory you updat=
e
> > > the CPU page table with a special entry. If the CPU try to access the
> > > virtual address with special entry it trigger fault and HMM will
> migrate
> > > the virtual address back to regular memory. But this does not apply f=
or
> > > CAPI or CCIX platform.
> > >
> >
> > the example of the virtual address using device physical memory is :
> gpu_r
> > =3D gpu_alloc(m*m*sizeof(float)),
> > so CPU want to access gpu_r will trigger migrate back to CPU memory,
> > it will allocate CPU page and copy
> > to gpu_r's content to CPU pages, right?
>
> No. Here we are always talking about virtual address that are the outcome
> of an mmap syscall either as private anonymous memory or as mmap of regul=
ar
> file (ie not a device file but a regular file on a filesystem).
>
> Device driver can migrate any virtual address to use device memory for
> performance reasons (how, why and when such migration happens is totaly
> opaque to HMM it is under the control of the device driver).
>
> So if you do:
>    BUFA =3D malloc(size);
> Then do something with BUFA on the CPU (like reading input or network, ..=
.)
> the memory is likely to be allocated with regular main memory (like DDR).
>
> Now if you start some job on your GPU that access BUFA the device driver
> might call migrate_vma() helper to migrate the memory to device memory. A=
t
> that point the virtual address of BUFA point to physical device memory he=
re
> CAPI or CCIX. If it is not CAPI/CCIX than the GPU page table point to
> device
> memory while the CPU page table point to invalid special entry. The GPU c=
an
> work on BUFA that now reside inside the device memory. Finaly, in the non
> CAPI/CCIX case, if CPU try to access that memory then a migration back to
> regular memory happen.
>

in this scenario:
*if CAPI/CCIX support=EF=BC=8C the CPU's page table and GPU's also point to=
 the
device physical page?
in this case, it still need the ZONE_DEVICE infrastructure for
CPU page table=EF=BC=9F

*if no CAPI/CCIX support, the CPU's page table filled a invalid special pte=
.


>
> What you really need is to decouple the virtual address part from what is
> the physical memory that is backing a virtual address. HMM provide helper=
s
> for both aspect. First to mirror page table so that every virtual address
> point to same physical address. Second side of HMM is to allow to use
> device
> memory transparently inside a process by allowing to migrate any virtual
> address to use device memory. Both aspect are orthogonal to each others.
>
> Cheers,
> J=C3=A9r=C3=B4me
>

--94eb2c1c0370fed6d405604782f2
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">2017-12-14 12:16 GMT+08:00 Jerome Glisse <span dir=3D"ltr">&lt;<a href=
=3D"mailto:jglisse@redhat.com" target=3D"_blank">jglisse@redhat.com</a>&gt;=
</span>:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bo=
rder-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On Thu, Dec 14,=
 2017 at 11:53:40AM +0800, Figo.zhang wrote:<br>
&gt; 2017-12-14 11:16 GMT+08:00 Jerome Glisse &lt;<a href=3D"mailto:jglisse=
@redhat.com">jglisse@redhat.com</a>&gt;:<br>
&gt;<br>
&gt; &gt; On Thu, Dec 14, 2017 at 10:48:36AM +0800, Figo.zhang wrote:<br>
&gt; &gt; &gt; 2017-12-14 0:12 GMT+08:00 Jerome Glisse &lt;<a href=3D"mailt=
o:jglisse@redhat.com">jglisse@redhat.com</a>&gt;:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; On Wed, Dec 13, 2017 at 08:10:42PM +0800, Figo.zhang wr=
ote:<br>
<br>
[...]<br>
<br>
</span><span class=3D"">&gt; &gt; This is not what happen. Here is the work=
flow with HMM mirror (note that<br>
&gt; &gt; physical address do not matter here so i do not even reference th=
em it is<br>
&gt; &gt; all about virtual address):<br>
&gt; &gt;=C2=A0 1 They are 3 buffers a, b and r at given virtual address bo=
th CPU and<br>
&gt; &gt;=C2=A0 =C2=A0 GPU can access them (concurently or not this does no=
t matter).<br>
&gt; &gt;=C2=A0 2 GPU can fault so if any virtual address do not have a pag=
e table<br>
&gt; &gt;=C2=A0 =C2=A0 entry inside the GPU page table this trigger a page =
fault that will<br>
&gt; &gt;=C2=A0 =C2=A0 call HMM mirror helper to snapshot CPU page table in=
to the GPU page<br>
&gt; &gt;=C2=A0 =C2=A0 table. If there is no physical memory backing the vi=
rtual address<br>
&gt; &gt;=C2=A0 =C2=A0 (ie CPU page table is also empty for the given virtu=
al address) then<br>
&gt; &gt;=C2=A0 =C2=A0 the regular page fault handler of the kernel is invo=
ked.<br>
&gt; &gt;<br>
&gt;<br>
&gt; so when HMM mirror done, the content of GPU page table entry and<br>
&gt; CPU page table entry<br>
&gt; are same, right? so the GPU and CPU can access the same physical addre=
ss,<br>
&gt; this physical<br>
&gt; address is allocated by CPU malloc systemcall. is it conflict and race=
<br>
&gt; condition? CPU and GPU<br>
&gt; write to this physical address concurrently.<br>
<br>
</span>Correct and yes it is conflict free. PCIE platform already support<b=
r>
cache coherent access by device to main memory (snoop transaction<br>
in PCIE specification). Access can happen concurently to same byte<br>
and it behave exactly the same as if two CPU core try to access the<br>
same byte.<br>
<span class=3D""><br>
&gt;<br>
&gt; i see this slides said:<br>
&gt; <a href=3D"http://on-demand.gputechconf.com/gtc/2017/presentation/s776=
4_john-hubbardgpus-using-hmm-blur-the-lines-between-cpu-and-gpu.pdf" rel=3D=
"noreferrer" target=3D"_blank">http://on-demand.gputechconf.<wbr>com/gtc/20=
17/presentation/<wbr>s7764_john-hubbardgpus-using-<wbr>hmm-blur-the-lines-b=
etween-<wbr>cpu-and-gpu.pdf</a><br>
&gt;<br>
&gt; in page 22~23=EF=BC=9A<br>
&gt; When CPU page fault occurs:<br>
&gt; * UM (unified memory driver) copies page data to CPU, umaps from GPU<b=
r>
&gt; *HMM maps page to CPU<br>
&gt;<br>
&gt; when GPU page fault occurs:<br>
&gt; *HMM has a malloc record buffer, so UM copy page data to GPU<br>
&gt; *HMM unmaps page from CPU<br>
&gt;<br>
&gt; so in this slides, it said it will has two copies, from CPU to GPU, an=
d<br>
&gt; from GPU to CPU. so in this case (mul_mat_on_gpu()), is it really need=
 two<br>
&gt; copies in kernel space?<br>
<br>
</span>This slide is for the case where you use device memory on PCIE platf=
orm.<br>
When that happen only the device can access the virtual address back by<br>
device memory. If CPU try to access such address a page fault is trigger<br=
>
and it migrate the data back to regular memory where both GPU and CPU can<b=
r>
access it concurently.<br>
<br>
And again this behavior only happen if you use HMM non cache coherent<br>
device memory model. If you use the device cache coherent model with HMM<br=
>
then CPU can access the device memory directly too and above scenario<br>
never happen.<br>
<br>
Note that memory copy when data move from device to system or from system<b=
r>
to device memory are inevitable. This is exactly as with autoNUMA. Also<br>
note that in some case thing can get allocated directly on GPU and never<br=
>
copied back to regular memory (only use by GPU and freed once GPU is done<b=
r>
with them) the zero copy case. But i want to stress that the zero copy<br>
case is unlikely to happen for input buffer. Usualy you do not get your<br>
input data set directly on the GPU but from network or disk and you might<b=
r>
do pre-processing on CPU (uncompress input, or do something that is better<=
br>
done on the CPU). Then you feed your data to the GPU and you do computation=
<br>
there.<br></blockquote><div><br></div><div>Great=EF=BC=81very=C2=A0detail=
=C2=A0about=C2=A0the HMM explanation, Thanks a=C2=A0lot.</div><div>so would=
 you=C2=A0like see my conclusion is=C2=A0correct?</div><div>* if=C2=A0suppo=
rt CCIX/CAPI, CPU can=C2=A0access GPU memory directly, and GPU=C2=A0also ca=
n=C2=A0access CPU=C2=A0memory directly,</div><div>so it no need=C2=A0copy o=
n=C2=A0kernel=C2=A0space in HMM solutions.</div><div><br></div><div>* if=C2=
=A0no=C2=A0support CCIX/CAPI, CPU=C2=A0cannot=C2=A0access GPU=C2=A0memory i=
n=C2=A0cache coherency=C2=A0method,=C2=A0also GPU=C2=A0cannot=C2=A0access C=
PU=C2=A0memory=C2=A0at</div><div>cache coherency. it=C2=A0need=C2=A0some co=
pies=C2=A0like John Hobburt&#39;s=C2=A0slides.</div><div>=C2=A0 =C2=A0*when=
 GPU=C2=A0page=C2=A0fault,=C2=A0need=C2=A0copy=C2=A0data=C2=A0from CPU=C2=
=A0page=C2=A0to GPU=C2=A0page, and HMM=C2=A0unmap the CPU=C2=A0page...</div=
><div>=C2=A0 =C2=A0*=C2=A0when CPU=C2=A0page=C2=A0fault,=C2=A0need=C2=A0cop=
y=C2=A0data=C2=A0from GPU=C2=A0page to CPU=C2=A0page and=C2=A0ummap GPU=C2=
=A0page and=C2=A0map the CPU=C2=A0page...</div><div>=C2=A0</div><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex">
<span class=3D""><br>
<br>
&gt; &gt; Without HMM mirror but ATS/PASI (CCIX or CAPI):<br>
&gt; &gt;=C2=A0 1 They are 3 buffers a, b and r at given virtual address bo=
th CPU and<br>
&gt; &gt;=C2=A0 =C2=A0 GPU can access them (concurently or not this does no=
t matter).<br>
&gt; &gt;=C2=A0 2 GPU use the exact same page table as the CPU and fault ex=
actly like<br>
&gt; &gt;=C2=A0 =C2=A0 CPU on empty page table entry<br>
&gt; &gt;<br>
&gt; &gt; So in the end with HMM mirror or ATS/PASID you get the same behav=
ior.<br>
&gt; &gt; There is no complexity like you seem to assume. This all about vi=
rtual<br>
&gt; &gt; address. At any point in time any given valid virtual address of =
a process<br>
&gt; &gt; point to a given physical memory address and that physical memory=
 address<br>
&gt; &gt; is the same on both the CPU and the GPU at any point in time they=
 are<br>
&gt; &gt; never out of sync (both in HMM mirror and in ATS/PASID case).<br>
&gt; &gt;<br>
&gt; &gt; The exception is for platform that do not have CAPI or CCIX prope=
rty ie<br>
&gt; &gt; cache coherency for CPU access to device memory. On such platform=
 when<br>
&gt; &gt; you migrate a virtual address to use device physical memory you u=
pdate<br>
&gt; &gt; the CPU page table with a special entry. If the CPU try to access=
 the<br>
&gt; &gt; virtual address with special entry it trigger fault and HMM will =
migrate<br>
&gt; &gt; the virtual address back to regular memory. But this does not app=
ly for<br>
&gt; &gt; CAPI or CCIX platform.<br>
&gt; &gt;<br>
&gt;<br>
&gt; the example of the virtual address using device physical memory is : g=
pu_r<br>
&gt; =3D gpu_alloc(m*m*sizeof(float)),<br>
&gt; so CPU want to access gpu_r will trigger migrate back to CPU memory,<b=
r>
&gt; it will allocate CPU page and copy<br>
&gt; to gpu_r&#39;s content to CPU pages, right?<br>
<br>
</span>No. Here we are always talking about virtual address that are the ou=
tcome<br>
of an mmap syscall either as private anonymous memory or as mmap of regular=
<br>
file (ie not a device file but a regular file on a filesystem).<br>
<br>
Device driver can migrate any virtual address to use device memory for<br>
performance reasons (how, why and when such migration happens is totaly<br>
opaque to HMM it is under the control of the device driver).<br>
<br>
So if you do:<br>
=C2=A0 =C2=A0BUFA =3D malloc(size);<br>
Then do something with BUFA on the CPU (like reading input or network, ...)=
<br>
the memory is likely to be allocated with regular main memory (like DDR).<b=
r>
<br>
Now if you start some job on your GPU that access BUFA the device driver<br=
>
might call migrate_vma() helper to migrate the memory to device memory. At<=
br>
that point the virtual address of BUFA point to physical device memory here=
<br>
CAPI or CCIX. If it is not CAPI/CCIX than the GPU page table point to devic=
e<br>
memory while the CPU page table point to invalid special entry. The GPU can=
<br>
work on BUFA that now reside inside the device memory. Finaly, in the non<b=
r>
CAPI/CCIX case, if CPU try to access that memory then a migration back to<b=
r>
regular memory happen.<br></blockquote><div>=C2=A0</div><div>in=C2=A0this=
=C2=A0scenario:</div><div>*if CAPI/CCIX=C2=A0support=EF=BC=8C the CPU&#39;s=
 page table and GPU&#39;s also point to the device physical page?</div><div=
>in this case, it=C2=A0still need the ZONE_DEVICE=C2=A0infrastructure=C2=A0=
for CPU=C2=A0page=C2=A0table=EF=BC=9F</div><div><br></div><div>*if no CAPI/=
CCIX support, the CPU&#39;s page table filled a invalid special pte.</div><=
div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex">
<br>
<br>
What you really need is to decouple the virtual address part from what is<b=
r>
the physical memory that is backing a virtual address. HMM provide helpers<=
br>
for both aspect. First to mirror page table so that every virtual address<b=
r>
point to same physical address. Second side of HMM is to allow to use devic=
e<br>
memory transparently inside a process by allowing to migrate any virtual<br=
>
address to use device memory. Both aspect are orthogonal to each others.<br=
>
<br>
Cheers,<br>
J=C3=A9r=C3=B4me<br>
</blockquote></div><br></div></div>

--94eb2c1c0370fed6d405604782f2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
