Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id EB0816B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 21:48:38 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id v137so1959216oia.21
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 18:48:38 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j131sor1093078oif.84.2017.12.13.18.48.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 18:48:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171213161247.GA2927@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com> <CAF7GXvqSZzNHdefQWhEb2SDYWX5hDWqQX7cayuVEQ8YyTULPog@mail.gmail.com>
 <20171213161247.GA2927@redhat.com>
From: "Figo.zhang" <figo1802@gmail.com>
Date: Thu, 14 Dec 2017 10:48:36 +0800
Message-ID: <CAF7GXvrxo2xj==wA_=fXr+9nF0k0Ed123kZXeKWKBHS6TKYNdA@mail.gmail.com>
Subject: Re: [HMM-v25 00/19] HMM (Heterogeneous Memory Management) v25
Content-Type: multipart/alternative; boundary="001a113dda4eb4809b056043ebf3"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>

--001a113dda4eb4809b056043ebf3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

2017-12-14 0:12 GMT+08:00 Jerome Glisse <jglisse@redhat.com>:

> On Wed, Dec 13, 2017 at 08:10:42PM +0800, Figo.zhang wrote:
> > it mention that HMM provided two functions:
> >
> > 1. one is mirror the page table between CPU and a device(like GPU, FPGA=
),
> > so i am confused that:  duplicating the CPU page table into a device pa=
ge
> > table means
> >
> > that copy the CPU page table entry into device page table? so the devic=
e
> > can access the CPU's virtual address? and that device can access the th=
e
> CPU
> > allocated physical memory which map into this VMA, right?
> >
> > for example:  VMA -> PA (CPU physical address)
> >
> > mirror: fill the the PTE entry of this VMA into GPU's  page table
> >
> > so:
> >
> > For CPU's view: it can access the PA
> >
> > For GPU's view: it can access the CPU's VMA and PA
> >
> > right?
>
> Correct. This is for platform/device without ATS/PASID. Note that
> HMM only provide helpers to snapshot the CPU page table and properly
> synchronize with concurrent CPU page table update. Most of the code
> is really inside the device driver as each device driver has its own
> architecture and its own page table format.
>
>
> > 2. other function is migrate CPU memory to device memory, what is the
> > application scenario ?
>
> Second part of HMM is to allow to register "special" struct page
> (they are not on the LRU and are associated with a device). Having
> struct page allow most of the kernel memory management to be
> oblivous to the underlying memory type (regular DDR memort or device
> memory).
>
> The migrate helper introduced with HMM is to allow to migrate to
> and from device memory using DMA engine and not CPU memcopy. It
> is needed because on some platform CPU can not access the device
> memory and moreover DMA engine reach higher bandwidth more easily
> than CPU memcopy.
>
> Again this is an helper. The policy on what to migrate, when, ...
> is outside HMM for now we assume that the device driver is the
> best place to have this logic. Maybe in few year once we have more
> device driver using that kind of feature we may grow common code
> to expose common API to userspace for migration policy.


>
> > some input data created by GPU and migrate back to CPU memory? use for
> CPU
> > to access GPU's data?
>
> It can be use in any number of way. So yes all the scenario you
> list do apply. On platform where CPU can not access device memory
> you need to migrate back to regular memory for CPU access.
>
> Note that the physical memory use behind a virtual address pointer
> is transparent to the application thus you do not need to modify
> it in anyway. That is the whole point of HMM.
>
>
> > 3. function one is help the GPU to access CPU's VMA and  CPU's physical
> > memory, if CPU want to access GPU's memory, still need to
> > specification device driver API like IOCTL+mmap+DMA?
>
> No you do not need special memory allocator with an HMM capable
> device (and device driver). HMM mirror functionality is to allow
> any pointer to point to same memory on both a device and CPU for
> a given application. This is the Fine-Grained system SVM as
> specified in the OpenCL 2.0 specification.
>
> Basic example is without HMM:
>     mul_mat_on_gpu(float *r, float *a, float *b, unsigned m)
>     {
>         gpu_buffer_t gpu_r, gpu_a, gpu_b;
>
>         gpu_r =3D gpu_alloc(m*m*sizeof(float));
>         gpu_a =3D gpu_alloc(m*m*sizeof(float));
>         gpu_b =3D gpu_alloc(m*m*sizeof(float));
>         gpu_copy_to(gpu_a, a, m*m*sizeof(float));
>         gpu_copy_to(gpu_b, b, m*m*sizeof(float));
>
>         gpu_mul_mat(gpu_r, gpu_a, gpu_b, m);
>
>         gpu_copy_from(gpu_r, r, m*m*sizeof(float));
>     }
>

The traditional workflow is:
1. the pointer a, b and r are total point to the CPU memory
2. create/alloc three GPU buffers: gpu_a, gpu_b, gpu_r
3. copy CPU memory a and b to GPU memory gpu_b and gpu_b
4. let the GPU to do the calculation
5.  copy the result from GPU buffer (gpu_r) to CPU buffer (r)

is it right?


>
> With HMM:
>     mul_mat_on_gpu(float *r, float *a, float *b, unsigned m)
>     {
>         gpu_mul_mat(r, a, b, m);
>     }
>

with HMM workflow:
1. CPU has three buffer: a, b, r, and it is physical addr is : pa, pb, pr
     and GPU has tree physical buffer: gpu_a, gpu_b, gpu_r
2. GPU want to access buffer a and b, cause a GPU page fault
3. GPU report a page fault to CPU
4. CPU got a GPU page fault:
                * unmap the buffer a,b,r (who do it? GPU driver?)
                * copy the buffer a ,b's content to GPU physical buffers:
gpu_a, gpu_b
                * fill the GPU page table entry with these pages (gpu_a,
gpu_b, gpu_r) of the CPU virtual address: a,b,r;

5. GPU do the calculation
6. CPU want to get result from buffer r and will cause a CPU page fault:
7. in CPU page fault:
             * unmap the GPU page table entry for virtual address a,b,r.
(who do the unmap? GPU driver?)
             * copy the GPU's buffer content (gpu_a, gpu_b, gpu_r) to
CPU buffer (abr)
             * fill the CPU page table entry: virtual_addr -> buffer
(pa,pb,pr)
8. so the CPU can get the result form buffer r.

my guess workflow is right?
it seems need two copy, from CPU to GPU, and then GPU to CPU for result.
* is it CPU and GPU have the  page table concurrently, so
no page fault occur?
* how about the performance? it sounds will create lots of page fault.


> So it is going from a world with device specific allocation
> to a model where any regular process memory (outcome of an
> mmap to a regular file or for anonymous private memory). can
> be access by both CPU and GPU using same pointer.
>
>
> Now on platform like PCIE where CPU can not access the device
> memory in cache coherent way (also with no garanty regarding
> CPU atomic operations) you can not have the CPU access the device
> memory without breaking memory model expected by the programmer.
>
> Hence if some range of the virtual address space of a process
> has been migrated to device memory it must be migrated back to
> regular memory.
>
> On platform like CAPI or CCIX you do not need to migrate back
> to regular memory on CPU access. HMM provide helpers to handle
> both cases.
>
>
> > 4. is it any example? i remember it has a dummy driver in older patchse=
t
> > version. i canot find in this version.
>
> Dummy driver and userspace:
> https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dhmm-next
> https://github.com/glisse/hmm-dummy-test-suite
>
> nouveau prototype:
> https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dhmm-nouveau
>
> I was waiting on rework of nouveau memory management before
> working on final implementation of HMM inside nouveau. That
> rework is now mostly ready:
>
> https://github.com/skeggsb/nouveau/tree/devel-fault
>
> I intend to start working on final HMM inside nouveau after
> the end of year celebration and i hope to have it in some
> working state in couple month. At the same time we are working
> on an open source userspace to make use of that (probably
> an OpenCL runtime first but we are looking into other thing
> such as OpenMP, CUDA, ...).
>
> Plans is to upstream all this next year, all the bits are
> slowly cooking.
>
> Cheers,
> J=C3=A9r=C3=B4me
>

--001a113dda4eb4809b056043ebf3
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">2017-12-14 0:12 GMT+08:00 Jerome Glisse <span dir=3D"ltr">&lt;<a href=
=3D"mailto:jglisse@redhat.com" target=3D"_blank">jglisse@redhat.com</a>&gt;=
</span>:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0=
.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex"><span class=
=3D"gmail-">On Wed, Dec 13, 2017 at 08:10:42PM +0800, Figo.zhang wrote:<br>
&gt; it mention that HMM provided two functions:<br>
&gt;<br>
&gt; 1. one is mirror the page table between CPU and a device(like GPU, FPG=
A),<br>
&gt; so i am confused that:=C2=A0 duplicating the CPU page table into a dev=
ice page<br>
&gt; table means<br>
&gt;<br>
&gt; that copy the CPU page table entry into device page table? so the devi=
ce<br>
&gt; can access the CPU&#39;s virtual address? and that device can access t=
he the CPU<br>
&gt; allocated physical memory which map into this VMA, right?<br>
&gt;<br>
&gt; for example:=C2=A0 VMA -&gt; PA (CPU physical address)<br>
&gt;<br>
&gt; mirror: fill the the PTE entry of this VMA into GPU&#39;s=C2=A0 page t=
able<br>
&gt;<br>
&gt; so:<br>
&gt;<br>
&gt; For CPU&#39;s view: it can access the PA<br>
&gt;<br>
&gt; For GPU&#39;s view: it can access the CPU&#39;s VMA and PA<br>
&gt;<br>
&gt; right?<br>
<br>
</span>Correct. This is for platform/device without ATS/PASID. Note that<br=
>
HMM only provide helpers to snapshot the CPU page table and properly<br>
synchronize with concurrent CPU page table update. Most of the code<br>
is really inside the device driver as each device driver has its own<br>
architecture and its own page table format.<br>
<span class=3D"gmail-"><br>
<br>
&gt; 2. other function is migrate CPU memory to device memory, what is the<=
br>
&gt; application scenario ?<br>
<br>
</span>Second part of HMM is to allow to register &quot;special&quot; struc=
t page<br>
(they are not on the LRU and are associated with a device). Having<br>
struct page allow most of the kernel memory management to be<br>
oblivous to the underlying memory type (regular DDR memort or device<br>
memory).<br>
<br>
The migrate helper introduced with HMM is to allow to migrate to<br>
and from device memory using DMA engine and not CPU memcopy. It<br>
is needed because on some platform CPU can not access the device<br>
memory and moreover DMA engine reach higher bandwidth more easily<br>
than CPU memcopy.<br>
<br>
Again this is an helper. The policy on what to migrate, when, ...<br>
is outside HMM for now we assume that the device driver is the<br>
best place to have this logic. Maybe in few year once we have more<br>
device driver using that kind of feature we may grow common code<br>
to expose common API to userspace for migration policy.</blockquote><blockq=
uote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1p=
x solid rgb(204,204,204);padding-left:1ex">
<span class=3D"gmail-"><br>
<br>
&gt; some input data created by GPU and migrate back to CPU memory? use for=
 CPU<br>
&gt; to access GPU&#39;s data?<br>
<br>
</span>It can be use in any number of way. So yes all the scenario you<br>
list do apply. On platform where CPU can not access device memory<br>
you need to migrate back to regular memory for CPU access.<br>
<br>
Note that the physical memory use behind a virtual address pointer<br>
is transparent to the application thus you do not need to modify<br>
it in anyway. That is the whole point of HMM.<br>
<span class=3D"gmail-"><br>
<br>
&gt; 3. function one is help the GPU to access CPU&#39;s VMA and=C2=A0 CPU&=
#39;s physical<br>
&gt; memory, if CPU want to access GPU&#39;s memory, still need to<br>
&gt; specification device driver API like IOCTL+mmap+DMA?<br>
<br>
</span>No you do not need special memory allocator with an HMM capable<br>
device (and device driver). HMM mirror functionality is to allow<br>
any pointer to point to same memory on both a device and CPU for<br>
a given application. This is the Fine-Grained system SVM as<br>
specified in the OpenCL 2.0 specification.<br>
<br>
Basic example is without HMM:<br>
=C2=A0 =C2=A0 mul_mat_on_gpu(float *r, float *a, float *b, unsigned m)<br>
=C2=A0 =C2=A0 {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 gpu_buffer_t gpu_r, gpu_a, gpu_b;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 gpu_r =3D gpu_alloc(m*m*sizeof(float));<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 gpu_a =3D gpu_alloc(m*m*sizeof(float));<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 gpu_b =3D gpu_alloc(m*m*sizeof(float));<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 gpu_copy_to(gpu_a, a, m*m*sizeof(float));<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 gpu_copy_to(gpu_b, b, m*m*sizeof(float));<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 gpu_mul_mat(gpu_r, gpu_a, gpu_b, m);<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 gpu_copy_from(gpu_r, r, m*m*sizeof(float));<br>
=C2=A0 =C2=A0 }<br></blockquote><div><br></div><div>The traditional workflo=
w is:</div><div>1. the pointer a, b and r are total point to the CPU memory=
</div><div>2. create/alloc three GPU buffers: gpu_a, gpu_b, gpu_r</div><div=
>3. copy CPU memory a and b to GPU=C2=A0memory gpu_b and gpu_b</div><div>4.=
 let the GPU to do the calculation=C2=A0</div><div>5.=C2=A0 copy the=C2=A0r=
esult=C2=A0from GPU=C2=A0buffer (gpu_r) to CPU=C2=A0buffer (r)</div><div><b=
r></div><div>is it=C2=A0right?</div><div>=C2=A0</div><blockquote class=3D"g=
mail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204=
,204,204);padding-left:1ex">
<br>
With HMM:<br>
=C2=A0 =C2=A0 mul_mat_on_gpu(float *r, float *a, float *b, unsigned m)<br>
=C2=A0 =C2=A0 {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 gpu_mul_mat(r, a, b, m);<br>
=C2=A0 =C2=A0 }<br></blockquote><div><br></div><div>with HMM=C2=A0workflow:=
</div><div>1. CPU has=C2=A0three=C2=A0buffer:=C2=A0a,=C2=A0b,=C2=A0r, and i=
t is physical addr is : pa, pb, pr=C2=A0</div><div>=C2=A0 =C2=A0 =C2=A0and =
GPU has=C2=A0tree physical buffer: gpu_a, gpu_b, gpu_r</div><div>2. GPU=C2=
=A0want=C2=A0to=C2=A0access=C2=A0buffer=C2=A0a=C2=A0and=C2=A0b,=C2=A0cause =
a GPU=C2=A0page=C2=A0fault</div><div>3. GPU=C2=A0report a=C2=A0page=C2=A0fa=
ult to CPU</div><div>4. CPU got=C2=A0a GPU=C2=A0page=C2=A0fault:</div><div>=
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * unmap the=C2=A0bu=
ffer=C2=A0a,b,r (who do=C2=A0it? GPU=C2=A0driver?)</div><div>=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * copy the=C2=A0buffer=C2=A0a ,b&=
#39;s=C2=A0content=C2=A0to GPU physical buffers: gpu_a, gpu_b</div><div>=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * fill the GPU=C2=A0pa=
ge=C2=A0table=C2=A0entry=C2=A0with=C2=A0these=C2=A0pages (gpu_a, gpu_b, gpu=
_r)=C2=A0of=C2=A0the CPU virtual=C2=A0address: a,b,r;=C2=A0</div><div><br><=
/div><div>5. GPU do the calculation=C2=A0</div><div>6. CPU=C2=A0want to=C2=
=A0get=C2=A0result=C2=A0from=C2=A0buffer=C2=A0r=C2=A0and=C2=A0will=C2=A0cau=
se a CPU=C2=A0page=C2=A0fault:</div><div>7.=C2=A0in CPU=C2=A0page=C2=A0faul=
t:=C2=A0</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* unmap =
the GPU=C2=A0page=C2=A0table=C2=A0entry=C2=A0for=C2=A0virtual=C2=A0address=
=C2=A0a,b,r. (who do the=C2=A0unmap? GPU=C2=A0driver?)</div><div>=C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* copy the GPU&#39;s=C2=A0buffer=C2=
=A0content (gpu_a, gpu_b, gpu_r) to CPU=C2=A0buffer (abr)=C2=A0</div><div>=
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* fill the CPU page table e=
ntry: virtual_addr -&gt; buffer (pa,pb,pr)</div><div>8. so the CPU can get =
the result form buffer r.</div><div><br></div><div>my guess workflow is rig=
ht?</div><div>it seems need two copy, from CPU to GPU, and then GPU to CPU =
for result.</div><div>* is it CPU and GPU have the=C2=A0 page table concurr=
ently, so no=C2=A0page=C2=A0fault=C2=A0occur?</div><div>* how about the=C2=
=A0performance? it sounds will create lots=C2=A0of=C2=A0page=C2=A0fault.</d=
iv><div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px=
 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">
<br>
So it is going from a world with device specific allocation<br>
to a model where any regular process memory (outcome of an<br>
mmap to a regular file or for anonymous private memory). can<br>
be access by both CPU and GPU using same pointer.<br>
<br>
<br>
Now on platform like PCIE where CPU can not access the device<br>
memory in cache coherent way (also with no garanty regarding<br>
CPU atomic operations) you can not have the CPU access the device<br>
memory without breaking memory model expected by the programmer.<br>
<br>
Hence if some range of the virtual address space of a process<br>
has been migrated to device memory it must be migrated back to<br>
regular memory.<br>
<br>
On platform like CAPI or CCIX you do not need to migrate back<br>
to regular memory on CPU access. HMM provide helpers to handle<br>
both cases.<br>
<span class=3D"gmail-"><br>
<br>
&gt; 4. is it any example? i remember it has a dummy driver in older patchs=
et<br>
&gt; version. i canot find in this version.<br>
<br>
</span>Dummy driver and userspace:<br>
<a href=3D"https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dhmm-next" re=
l=3D"noreferrer" target=3D"_blank">https://cgit.freedesktop.org/~<wbr>gliss=
e/linux/log/?h=3Dhmm-next</a><br>
<a href=3D"https://github.com/glisse/hmm-dummy-test-suite" rel=3D"noreferre=
r" target=3D"_blank">https://github.com/glisse/hmm-<wbr>dummy-test-suite</a=
><br>
<br>
nouveau prototype:<br>
<a href=3D"https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dhmm-nouveau"=
 rel=3D"noreferrer" target=3D"_blank">https://cgit.freedesktop.org/~<wbr>gl=
isse/linux/log/?h=3Dhmm-<wbr>nouveau</a><br>
<br>
I was waiting on rework of nouveau memory management before<br>
working on final implementation of HMM inside nouveau. That<br>
rework is now mostly ready:<br>
<br>
<a href=3D"https://github.com/skeggsb/nouveau/tree/devel-fault" rel=3D"nore=
ferrer" target=3D"_blank">https://github.com/skeggsb/<wbr>nouveau/tree/deve=
l-fault</a><br>
<br>
I intend to start working on final HMM inside nouveau after<br>
the end of year celebration and i hope to have it in some<br>
working state in couple month. At the same time we are working<br>
on an open source userspace to make use of that (probably<br>
an OpenCL runtime first but we are looking into other thing<br>
such as OpenMP, CUDA, ...).<br>
<br>
Plans is to upstream all this next year, all the bits are<br>
slowly cooking.<br>
<br>
Cheers,<br>
J=C3=A9r=C3=B4me<br>
</blockquote></div><br></div></div>

--001a113dda4eb4809b056043ebf3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
