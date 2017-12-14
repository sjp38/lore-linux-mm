Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 67D706B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 22:53:42 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id t47so2392430otd.19
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 19:53:42 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n185sor1085030oia.253.2017.12.13.19.53.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 19:53:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171214031607.GA17710@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com> <CAF7GXvqSZzNHdefQWhEb2SDYWX5hDWqQX7cayuVEQ8YyTULPog@mail.gmail.com>
 <20171213161247.GA2927@redhat.com> <CAF7GXvrxo2xj==wA_=fXr+9nF0k0Ed123kZXeKWKBHS6TKYNdA@mail.gmail.com>
 <20171214031607.GA17710@redhat.com>
From: "Figo.zhang" <figo1802@gmail.com>
Date: Thu, 14 Dec 2017 11:53:40 +0800
Message-ID: <CAF7GXvqoYXDJNYcrzJo5bGvfBG9iFq8PbeA7RO7y+9DuM7N0og@mail.gmail.com>
Subject: Re: [HMM-v25 00/19] HMM (Heterogeneous Memory Management) v25
Content-Type: multipart/alternative; boundary="001a1134e37c646e13056044d4db"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>

--001a1134e37c646e13056044d4db
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

2017-12-14 11:16 GMT+08:00 Jerome Glisse <jglisse@redhat.com>:

> On Thu, Dec 14, 2017 at 10:48:36AM +0800, Figo.zhang wrote:
> > 2017-12-14 0:12 GMT+08:00 Jerome Glisse <jglisse@redhat.com>:
> >
> > > On Wed, Dec 13, 2017 at 08:10:42PM +0800, Figo.zhang wrote:
>
> [...]
>
> > > Basic example is without HMM:
> > >     mul_mat_on_gpu(float *r, float *a, float *b, unsigned m)
> > >     {
> > >         gpu_buffer_t gpu_r, gpu_a, gpu_b;
> > >
> > >         gpu_r =3D gpu_alloc(m*m*sizeof(float));
> > >         gpu_a =3D gpu_alloc(m*m*sizeof(float));
> > >         gpu_b =3D gpu_alloc(m*m*sizeof(float));
> > >         gpu_copy_to(gpu_a, a, m*m*sizeof(float));
> > >         gpu_copy_to(gpu_b, b, m*m*sizeof(float));
> > >
> > >         gpu_mul_mat(gpu_r, gpu_a, gpu_b, m);
> > >
> > >         gpu_copy_from(gpu_r, r, m*m*sizeof(float));
> > >     }
> > >
> >
> > The traditional workflow is:
> > 1. the pointer a, b and r are total point to the CPU memory
> > 2. create/alloc three GPU buffers: gpu_a, gpu_b, gpu_r
> > 3. copy CPU memory a and b to GPU memory gpu_b and gpu_b
> > 4. let the GPU to do the calculation
> > 5.  copy the result from GPU buffer (gpu_r) to CPU buffer (r)
> >
> > is it right?
>
> Right.
>
>
> > > With HMM:
> > >     mul_mat_on_gpu(float *r, float *a, float *b, unsigned m)
> > >     {
> > >         gpu_mul_mat(r, a, b, m);
> > >     }
> > >
> >
> > with HMM workflow:
> > 1. CPU has three buffer: a, b, r, and it is physical addr is : pa, pb, =
pr
> >      and GPU has tree physical buffer: gpu_a, gpu_b, gpu_r
> > 2. GPU want to access buffer a and b, cause a GPU page fault
> > 3. GPU report a page fault to CPU
> > 4. CPU got a GPU page fault:
> >                 * unmap the buffer a,b,r (who do it? GPU driver?)
> >                 * copy the buffer a ,b's content to GPU physical buffer=
s:
> > gpu_a, gpu_b
> >                 * fill the GPU page table entry with these pages (gpu_a=
,
> > gpu_b, gpu_r) of the CPU virtual address: a,b,r;
> >
> > 5. GPU do the calculation
> > 6. CPU want to get result from buffer r and will cause a CPU page fault=
:
> > 7. in CPU page fault:
> >              * unmap the GPU page table entry for virtual address a,b,r=
.
> > (who do the unmap? GPU driver?)
> >              * copy the GPU's buffer content (gpu_a, gpu_b, gpu_r) to
> > CPU buffer (abr)
> >              * fill the CPU page table entry: virtual_addr -> buffer
> > (pa,pb,pr)
> > 8. so the CPU can get the result form buffer r.
> >
> > my guess workflow is right?
> > it seems need two copy, from CPU to GPU, and then GPU to CPU for result=
.
> > * is it CPU and GPU have the  page table concurrently, so
> > no page fault occur?
> > * how about the performance? it sounds will create lots of page fault.
>
> This is not what happen. Here is the workflow with HMM mirror (note that
> physical address do not matter here so i do not even reference them it is
> all about virtual address):
>  1 They are 3 buffers a, b and r at given virtual address both CPU and
>    GPU can access them (concurently or not this does not matter).
>  2 GPU can fault so if any virtual address do not have a page table
>    entry inside the GPU page table this trigger a page fault that will
>    call HMM mirror helper to snapshot CPU page table into the GPU page
>    table. If there is no physical memory backing the virtual address
>    (ie CPU page table is also empty for the given virtual address) then
>    the regular page fault handler of the kernel is invoked.
>

so when HMM mirror done, the content of GPU page table entry and
CPU page table entry
are same, right? so the GPU and CPU can access the same physical address,
this physical
address is allocated by CPU malloc systemcall. is it conflict and race
condition? CPU and GPU
write to this physical address concurrently.

i see this slides said:
http://on-demand.gputechconf.com/gtc/2017/presentation/s7764_john-hubbardgp=
us-using-hmm-blur-the-lines-between-cpu-and-gpu.pdf

in page 22~23=EF=BC=9A
When CPU page fault occurs:
* UM (unified memory driver) copies page data to CPU, umaps from GPU
*HMM maps page to CPU

when GPU page fault occurs:
*HMM has a malloc record buffer, so UM copy page data to GPU
*HMM unmaps page from CPU

so in this slides, it said it will has two copies, from CPU to GPU, and
from GPU to CPU. so in this case (mul_mat_on_gpu()), is it really need two
copies in kernel space?


>
> Without HMM mirror but ATS/PASI (CCIX or CAPI):
>  1 They are 3 buffers a, b and r at given virtual address both CPU and
>    GPU can access them (concurently or not this does not matter).
>  2 GPU use the exact same page table as the CPU and fault exactly like
>    CPU on empty page table entry
>
> So in the end with HMM mirror or ATS/PASID you get the same behavior.
> There is no complexity like you seem to assume. This all about virtual
> address. At any point in time any given valid virtual address of a proces=
s
> point to a given physical memory address and that physical memory address
> is the same on both the CPU and the GPU at any point in time they are
> never out of sync (both in HMM mirror and in ATS/PASID case).
>
> The exception is for platform that do not have CAPI or CCIX property ie
> cache coherency for CPU access to device memory. On such platform when
> you migrate a virtual address to use device physical memory you update
> the CPU page table with a special entry. If the CPU try to access the
> virtual address with special entry it trigger fault and HMM will migrate
> the virtual address back to regular memory. But this does not apply for
> CAPI or CCIX platform.
>

the example of the virtual address using device physical memory is : gpu_r
=3D gpu_alloc(m*m*sizeof(float)),
so CPU want to access gpu_r will trigger migrate back to CPU memory,
it will allocate CPU page and copy
to gpu_r's content to CPU pages, right?



>
>
> Too minimize page fault the device driver is encourage to pre-fault and
> prepopulate its page table (the HMM mirror case). Often device driver has
> enough context information to guess what range of virtual address is
> about to be access by the device and thus pre-fault thing.
>
>
> Hope this clarify thing for you.
>
> Cheers,
> J=C3=A9r=C3=B4me
>

--001a1134e37c646e13056044d4db
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">2017-12-14 11:16 GMT+08:00 Jerome Glisse <span dir=3D"ltr">&lt;<a href=
=3D"mailto:jglisse@redhat.com" target=3D"_blank">jglisse@redhat.com</a>&gt;=
</span>:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0=
.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex"><span class=
=3D"gmail-">On Thu, Dec 14, 2017 at 10:48:36AM +0800, Figo.zhang wrote:<br>
&gt; 2017-12-14 0:12 GMT+08:00 Jerome Glisse &lt;<a href=3D"mailto:jglisse@=
redhat.com">jglisse@redhat.com</a>&gt;:<br>
&gt;<br>
&gt; &gt; On Wed, Dec 13, 2017 at 08:10:42PM +0800, Figo.zhang wrote:<br>
<br>
</span>[...]<br>
<span class=3D"gmail-"><br>
&gt; &gt; Basic example is without HMM:<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0mul_mat_on_gpu(float *r, float *a, float *b, u=
nsigned m)<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0{<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0gpu_buffer_t gpu_r, gpu_a, gpu_b=
;<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0gpu_r =3D gpu_alloc(m*m*sizeof(f=
loat));<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0gpu_a =3D gpu_alloc(m*m*sizeof(f=
loat));<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0gpu_b =3D gpu_alloc(m*m*sizeof(f=
loat));<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0gpu_copy_to(gpu_a, a, m*m*sizeof=
(float));<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0gpu_copy_to(gpu_b, b, m*m*sizeof=
(float));<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0gpu_mul_mat(gpu_r, gpu_a, gpu_b,=
 m);<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0gpu_copy_from(gpu_r, r, m*m*size=
of(float));<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt;<br>
&gt;<br>
&gt; The traditional workflow is:<br>
&gt; 1. the pointer a, b and r are total point to the CPU memory<br>
&gt; 2. create/alloc three GPU buffers: gpu_a, gpu_b, gpu_r<br>
&gt; 3. copy CPU memory a and b to GPU memory gpu_b and gpu_b<br>
&gt; 4. let the GPU to do the calculation<br>
&gt; 5.=C2=A0 copy the result from GPU buffer (gpu_r) to CPU buffer (r)<br>
&gt;<br>
&gt; is it right?<br>
<br>
</span>Right.<br>
<div><div class=3D"gmail-h5"><br>
<br>
&gt; &gt; With HMM:<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0mul_mat_on_gpu(float *r, float *a, float *b, u=
nsigned m)<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0{<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0gpu_mul_mat(r, a, b, m);<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt;<br>
&gt;<br>
&gt; with HMM workflow:<br>
&gt; 1. CPU has three buffer: a, b, r, and it is physical addr is : pa, pb,=
 pr<br>
&gt;=C2=A0 =C2=A0 =C2=A0 and GPU has tree physical buffer: gpu_a, gpu_b, gp=
u_r<br>
&gt; 2. GPU want to access buffer a and b, cause a GPU page fault<br>
&gt; 3. GPU report a page fault to CPU<br>
&gt; 4. CPU got a GPU page fault:<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* unmap t=
he buffer a,b,r (who do it? GPU driver?)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* copy th=
e buffer a ,b&#39;s content to GPU physical buffers:<br>
&gt; gpu_a, gpu_b<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* fill th=
e GPU page table entry with these pages (gpu_a,<br>
&gt; gpu_b, gpu_r) of the CPU virtual address: a,b,r;<br>
&gt;<br>
&gt; 5. GPU do the calculation<br>
&gt; 6. CPU want to get result from buffer r and will cause a CPU page faul=
t:<br>
&gt; 7. in CPU page fault:<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * unmap the GPU page t=
able entry for virtual address a,b,r.<br>
&gt; (who do the unmap? GPU driver?)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * copy the GPU&#39;s b=
uffer content (gpu_a, gpu_b, gpu_r) to<br>
&gt; CPU buffer (abr)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * fill the CPU page ta=
ble entry: virtual_addr -&gt; buffer<br>
&gt; (pa,pb,pr)<br>
&gt; 8. so the CPU can get the result form buffer r.<br>
&gt;<br>
&gt; my guess workflow is right?<br>
&gt; it seems need two copy, from CPU to GPU, and then GPU to CPU for resul=
t.<br>
&gt; * is it CPU and GPU have the=C2=A0 page table concurrently, so<br>
&gt; no page fault occur?<br>
&gt; * how about the performance? it sounds will create lots of page fault.=
<br>
<br>
</div></div>This is not what happen. Here is the workflow with HMM mirror (=
note that<br>
physical address do not matter here so i do not even reference them it is<b=
r>
all about virtual address):<br>
=C2=A01 They are 3 buffers a, b and r at given virtual address both CPU and=
<br>
=C2=A0 =C2=A0GPU can access them (concurently or not this does not matter).=
<br>
=C2=A02 GPU can fault so if any virtual address do not have a page table<br=
>
=C2=A0 =C2=A0entry inside the GPU page table this trigger a page fault that=
 will<br>
=C2=A0 =C2=A0call HMM mirror helper to snapshot CPU page table into the GPU=
 page<br>
=C2=A0 =C2=A0table. If there is no physical memory backing the virtual addr=
ess<br>
=C2=A0 =C2=A0(ie CPU page table is also empty for the given virtual address=
) then<br>
=C2=A0 =C2=A0the regular page fault handler of the kernel is invoked.<br></=
blockquote><div><br></div><div>so=C2=A0when HMM=C2=A0mirror=C2=A0done, the=
=C2=A0content of GPU=C2=A0page=C2=A0table=C2=A0entry and CPU=C2=A0page=C2=
=A0table=C2=A0entry=C2=A0</div><div>are=C2=A0same,=C2=A0right? so the GPU a=
nd CPU can access the=C2=A0same=C2=A0physical=C2=A0address, this physical=
=C2=A0</div><div>address is=C2=A0allocated=C2=A0by CPU=C2=A0malloc=C2=A0sys=
temcall. is it conflict and race condition? CPU and GPU=C2=A0</div><div>wri=
te to=C2=A0this physical=C2=A0address concurrently.</div><div><br></div><di=
v>i see this=C2=A0slides=C2=A0said:=C2=A0</div><div><a href=3D"http://on-de=
mand.gputechconf.com/gtc/2017/presentation/s7764_john-hubbardgpus-using-hmm=
-blur-the-lines-between-cpu-and-gpu.pdf">http://on-demand.gputechconf.com/g=
tc/2017/presentation/s7764_john-hubbardgpus-using-hmm-blur-the-lines-betwee=
n-cpu-and-gpu.pdf</a><br></div><div><br></div><div>in=C2=A0page 22~23=EF=BC=
=9A</div><div>When CPU=C2=A0page=C2=A0fault=C2=A0occurs:</div><div>* UM (un=
ified=C2=A0memory=C2=A0driver) copies=C2=A0page=C2=A0data to CPU,=C2=A0umap=
s=C2=A0from GPU</div><div>*HMM=C2=A0maps=C2=A0page to CPU</div><div><br></d=
iv><div>when GPU=C2=A0page=C2=A0fault=C2=A0occurs:</div><div>*HMM has a=C2=
=A0malloc=C2=A0record=C2=A0buffer,=C2=A0so UM=C2=A0copy=C2=A0page=C2=A0data=
 to GPU</div><div>*HMM=C2=A0unmaps=C2=A0page=C2=A0from CPU</div><div><br></=
div><div>so in this=C2=A0slides, it said it will has two=C2=A0copies,=C2=A0=
from CPU to GPU, and=C2=A0</div><div>from GPU to CPU.=C2=A0so in this=C2=A0=
case (mul_mat_on_gpu()), is it=C2=A0really=C2=A0need two copies in=C2=A0ker=
nel=C2=A0space?</div><div>=C2=A0</div><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);paddi=
ng-left:1ex">
<br>
Without HMM mirror but ATS/PASI (CCIX or CAPI):<br>
=C2=A01 They are 3 buffers a, b and r at given virtual address both CPU and=
<br>
=C2=A0 =C2=A0GPU can access them (concurently or not this does not matter).=
<br>
=C2=A02 GPU use the exact same page table as the CPU and fault exactly like=
<br>
=C2=A0 =C2=A0CPU on empty page table entry<br>
<br>
So in the end with HMM mirror or ATS/PASID you get the same behavior.<br>
There is no complexity like you seem to assume. This all about virtual<br>
address. At any point in time any given valid virtual address of a process<=
br>
point to a given physical memory address and that physical memory address<b=
r>
is the same on both the CPU and the GPU at any point in time they are<br>
never out of sync (both in HMM mirror and in ATS/PASID case).<br>
<br>
The exception is for platform that do not have CAPI or CCIX property ie<br>
cache coherency for CPU access to device memory. On such platform when<br>
you migrate a virtual address to use device physical memory you update<br>
the CPU page table with a special entry. If the CPU try to access the<br>
virtual address with special entry it trigger fault and HMM will migrate<br=
>
the virtual address back to regular memory. But this does not apply for<br>
CAPI or CCIX platform.<br></blockquote><div><br></div><div>the=C2=A0example=
 of the virtual=C2=A0address=C2=A0using=C2=A0device=C2=A0physical=C2=A0memo=
ry is : gpu_r =3D gpu_alloc(m*m*sizeof(float)),</div><div>so CPU want to=C2=
=A0access=C2=A0gpu_r=C2=A0will=C2=A0trigger=C2=A0migrate=C2=A0back to CPU=
=C2=A0memory, it=C2=A0will=C2=A0allocate CPU=C2=A0page and=C2=A0copy</div><=
div>to=C2=A0gpu_r&#39;s content to CPU=C2=A0pages,=C2=A0right?</div><div><b=
r></div><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:=
0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">
<br>
<br>
Too minimize page fault the device driver is encourage to pre-fault and<br>
prepopulate its page table (the HMM mirror case). Often device driver has<b=
r>
enough context information to guess what range of virtual address is<br>
about to be access by the device and thus pre-fault thing.<br>
<br>
<br>
Hope this clarify thing for you.<br>
<br>
Cheers,<br>
J=C3=A9r=C3=B4me<br>
</blockquote></div><br></div></div>

--001a1134e37c646e13056044d4db--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
