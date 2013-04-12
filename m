Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id C86226B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 23:21:18 -0400 (EDT)
Received: by mail-qe0-f45.google.com with SMTP id 1so1315622qee.32
        for <linux-mm@kvack.org>; Thu, 11 Apr 2013 20:21:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51677BCA.2050002@gmail.com>
References: <5114DF05.7070702@mellanox.com>
	<CANN689Ff6vSu4ZvHek4J4EMzFG7EjF-Ej48hJKV_4SrLoj+mCA@mail.gmail.com>
	<CAH3drwaACy5KFv_2ozEe35u1Jpxs0f6msKoW=3_0nrWZpJnO4w@mail.gmail.com>
	<5164C6EE.7020502@gmail.com>
	<20130410205557.GB3958@gmail.com>
	<51662FFF.10103@gmail.com>
	<20130411184806.GB6696@gmail.com>
	<51677BCA.2050002@gmail.com>
Date: Thu, 11 Apr 2013 23:21:17 -0400
Message-ID: <CAH3drwbomhKLk51+M=V_oKHqhH3Wsa-uHkRvk_cg_Sd8XPBgoA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Hardware initiated paging of user process pages,
 hardware access to the CPU page tables of user processes
From: Jerome Glisse <j.glisse@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b5db86c7453b104da216565
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Michel Lespinasse <walken@google.com>, Shachar Raindel <raindel@mellanox.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Roland Dreier <roland@purestorage.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Liran Liss <liranl@mellanox.com>

--047d7b5db86c7453b104da216565
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 11, 2013 at 11:13 PM, Simon Jeons <simon.jeons@gmail.com> wrote:

> Hi Jerome,
>
> On 04/12/2013 02:48 AM, Jerome Glisse wrote:
>
>> On Thu, Apr 11, 2013 at 11:37:35AM +0800, Simon Jeons wrote:
>>
>>> Hi Jerome,
>>> On 04/11/2013 04:55 AM, Jerome Glisse wrote:
>>>
>>>> On Wed, Apr 10, 2013 at 09:57:02AM +0800, Simon Jeons wrote:
>>>>
>>>>> Hi Jerome,
>>>>> On 02/10/2013 12:29 AM, Jerome Glisse wrote:
>>>>>
>>>>>> On Sat, Feb 9, 2013 at 1:05 AM, Michel Lespinasse <walken@google.com>
>>>>>> wrote:
>>>>>>
>>>>>>> On Fri, Feb 8, 2013 at 3:18 AM, Shachar Raindel <
>>>>>>> raindel@mellanox.com> wrote:
>>>>>>>
>>>>>>>> Hi,
>>>>>>>>
>>>>>>>> We would like to present a reference implementation for safely
>>>>>>>> sharing
>>>>>>>> memory pages from user space with the hardware, without pinning.
>>>>>>>>
>>>>>>>> We will be happy to hear the community feedback on our prototype
>>>>>>>> implementation, and suggestions for future improvements.
>>>>>>>>
>>>>>>>> We would also like to discuss adding features to the core MM
>>>>>>>> subsystem to
>>>>>>>> assist hardware access to user memory without pinning.
>>>>>>>>
>>>>>>> This sounds kinda scary TBH; however I do understand the need for
>>>>>>> such
>>>>>>> technology.
>>>>>>>
>>>>>>> I think one issue is that many MM developers are insufficiently aware
>>>>>>> of such developments; having a technology presentation would probably
>>>>>>> help there; but traditionally LSF/MM sessions are more interactive
>>>>>>> between developers who are already quite familiar with the
>>>>>>> technology.
>>>>>>> I think it would help if you could send in advance a detailed
>>>>>>> presentation of the problem and the proposed solutions (and then what
>>>>>>> they require of the MM layer) so people can be better prepared.
>>>>>>>
>>>>>>> And first I'd like to ask, aren't IOMMUs supposed to already largely
>>>>>>> solve this problem ? (probably a dumb question, but that just tells
>>>>>>> you how much you need to explain :)
>>>>>>>
>>>>>> For GPU the motivation is three fold. With the advance of GPU compute
>>>>>> and also with newer graphic program we see a massive increase in GPU
>>>>>> memory consumption. We easily can reach buffer that are bigger than
>>>>>> 1gbytes. So the first motivation is to directly use the memory the
>>>>>> user allocated through malloc in the GPU this avoid copying 1gbytes of
>>>>>> data with the cpu to the gpu buffer. The second and mostly important
>>>>>> to GPU compute is the use of GPU seamlessly with the CPU, in order to
>>>>>> achieve this you want the programmer to have a single address space on
>>>>>> the CPU and GPU. So that the same address point to the same object on
>>>>>> GPU as on the CPU. This would also be a tremendous cleaner design from
>>>>>> driver point of view toward memory management.
>>>>>>
>>>>> When GPU will comsume memory?
>>>>>
>>>>> The userspace process like mplayer will have video datas and GPU
>>>>> will play this datas and use memory of mplayer since these video
>>>>> datas load in mplayer process's address space? So GPU codes will
>>>>> call gup to take a reference of memory? Please correct me if my
>>>>> understanding is wrong. ;-)
>>>>>
>>>> First target is not thing such as video decompression, however they
>>>> could
>>>> too benefit from it given updated driver kernel API. In case of using
>>>> iommu hardware page fault we don't call get_user_pages (gup) those we
>>>> don't take a reference on the page. That's the whole point of the
>>>> hardware
>>>> pagefault, not taking reference on the page.
>>>>
>>> mplayer process is running on normal CPU or GPU?
>>> chipset_integrated graphics will use normal memory and discrete
>>> graphics will use its own memory, correct? So the memory used by
>>> discrete graphics won't need gup, correct?
>>>
>> mplayer can decode video in software an only use the cpu. It can also use
>> one of the accleration API such as VDPAU. In any case mplayer is still
>> opening
>> the video file allocating some memory with malloc, reading from file into
>> this memory eventually do some preprocessing on that memory and then
>> memcpy from this memory to memory allocated by the gpu driver.
>>
>> No imagine a world where you don't have to memcpy so that the gpu can
>> access
>> it. Even if it's doable today it's really not something you want todo, ie
>> gup on page and not releasing page for minutes.
>>
>> There is two kind of integrated GPU, on x86 integrated GPU should be
>> considered
>> as discrete GPU because BIOS steal a chunk of system ram and transform it
>> in
>> fake vram. This stolen chunk is never ever under the control of the linux
>> kernel
>> (from mm pov the gpu kernel driver is in charge of it).
>>
>
> I configure integrated GPU in BIOS during system boot, it's seems that we
> can preallocate memory for integrated GPU, is this the memory you mentioned
> ?


Most likely it's


> In any case both discrete GPU and integrated GPU have their own page table
>> or
>>
>
> Discrete GPU will not use normal memory even if their own memory is
> exhaused, correct?
>
>
They will consume normal memory, right now you can see that on heavy load
hugue chunk of your system memory disappear, it's the gpu driver that is
using it, it get mapped into gpu address space and from gpu unit pov it's
just like any other memory (ie vram or sram looks the same to the gpu
acceleration core, sram is just slower).

Cheers
Jerome

--047d7b5db86c7453b104da216565
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 11, 2013 at 11:13 PM, Simon Jeons <span dir=3D"ltr">&lt;<a href=
=3D"mailto:simon.jeons@gmail.com" target=3D"_blank">simon.jeons@gmail.com</=
a>&gt;</span> wrote:<br><div class=3D"gmail_quote"><blockquote class=3D"gma=
il_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-lef=
t:1ex">
Hi Jerome,<div><div class=3D"h5"><br>
On 04/12/2013 02:48 AM, Jerome Glisse wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
On Thu, Apr 11, 2013 at 11:37:35AM +0800, Simon Jeons wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
Hi Jerome,<br>
On 04/11/2013 04:55 AM, Jerome Glisse wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
On Wed, Apr 10, 2013 at 09:57:02AM +0800, Simon Jeons wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
Hi Jerome,<br>
On 02/10/2013 12:29 AM, Jerome Glisse wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
On Sat, Feb 9, 2013 at 1:05 AM, Michel Lespinasse &lt;<a href=3D"mailto:wal=
ken@google.com" target=3D"_blank">walken@google.com</a>&gt; wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
On Fri, Feb 8, 2013 at 3:18 AM, Shachar Raindel &lt;<a href=3D"mailto:raind=
el@mellanox.com" target=3D"_blank">raindel@mellanox.com</a>&gt; wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
Hi,<br>
<br>
We would like to present a reference implementation for safely sharing<br>
memory pages from user space with the hardware, without pinning.<br>
<br>
We will be happy to hear the community feedback on our prototype<br>
implementation, and suggestions for future improvements.<br>
<br>
We would also like to discuss adding features to the core MM subsystem to<b=
r>
assist hardware access to user memory without pinning.<br>
</blockquote>
This sounds kinda scary TBH; however I do understand the need for such<br>
technology.<br>
<br>
I think one issue is that many MM developers are insufficiently aware<br>
of such developments; having a technology presentation would probably<br>
help there; but traditionally LSF/MM sessions are more interactive<br>
between developers who are already quite familiar with the technology.<br>
I think it would help if you could send in advance a detailed<br>
presentation of the problem and the proposed solutions (and then what<br>
they require of the MM layer) so people can be better prepared.<br>
<br>
And first I&#39;d like to ask, aren&#39;t IOMMUs supposed to already largel=
y<br>
solve this problem ? (probably a dumb question, but that just tells<br>
you how much you need to explain :)<br>
</blockquote>
For GPU the motivation is three fold. With the advance of GPU compute<br>
and also with newer graphic program we see a massive increase in GPU<br>
memory consumption. We easily can reach buffer that are bigger than<br>
1gbytes. So the first motivation is to directly use the memory the<br>
user allocated through malloc in the GPU this avoid copying 1gbytes of<br>
data with the cpu to the gpu buffer. The second and mostly important<br>
to GPU compute is the use of GPU seamlessly with the CPU, in order to<br>
achieve this you want the programmer to have a single address space on<br>
the CPU and GPU. So that the same address point to the same object on<br>
GPU as on the CPU. This would also be a tremendous cleaner design from<br>
driver point of view toward memory management.<br>
</blockquote>
When GPU will comsume memory?<br>
<br>
The userspace process like mplayer will have video datas and GPU<br>
will play this datas and use memory of mplayer since these video<br>
datas load in mplayer process&#39;s address space? So GPU codes will<br>
call gup to take a reference of memory? Please correct me if my<br>
understanding is wrong. ;-)<br>
</blockquote>
First target is not thing such as video decompression, however they could<b=
r>
too benefit from it given updated driver kernel API. In case of using<br>
iommu hardware page fault we don&#39;t call get_user_pages (gup) those we<b=
r>
don&#39;t take a reference on the page. That&#39;s the whole point of the h=
ardware<br>
pagefault, not taking reference on the page.<br>
</blockquote>
mplayer process is running on normal CPU or GPU?<br>
chipset_integrated graphics will use normal memory and discrete<br>
graphics will use its own memory, correct? So the memory used by<br>
discrete graphics won&#39;t need gup, correct?<br>
</blockquote>
mplayer can decode video in software an only use the cpu. It can also use<b=
r>
one of the accleration API such as VDPAU. In any case mplayer is still open=
ing<br>
the video file allocating some memory with malloc, reading from file into<b=
r>
this memory eventually do some preprocessing on that memory and then<br>
memcpy from this memory to memory allocated by the gpu driver.<br>
<br>
No imagine a world where you don&#39;t have to memcpy so that the gpu can a=
ccess<br>
it. Even if it&#39;s doable today it&#39;s really not something you want to=
do, ie<br>
gup on page and not releasing page for minutes.<br>
<br>
There is two kind of integrated GPU, on x86 integrated GPU should be consid=
ered<br>
as discrete GPU because BIOS steal a chunk of system ram and transform it i=
n<br>
fake vram. This stolen chunk is never ever under the control of the linux k=
ernel<br>
(from mm pov the gpu kernel driver is in charge of it).<br>
</blockquote>
<br></div></div>
I configure integrated GPU in BIOS during system boot, it&#39;s seems that =
we can preallocate memory for integrated GPU, is this the memory you mentio=
ned ?
</blockquote><div><br>Most likely it&#39;s<br>=A0</div><blockquote class=3D=
"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding=
-left:1ex"><div class=3D"im"><blockquote class=3D"gmail_quote" style=3D"mar=
gin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">

In any case both discrete GPU and integrated GPU have their own page table =
or<br>
</blockquote>
<br></div>
Discrete GPU will not use normal memory even if their own memory is exhause=
d, correct?<div class=3D"HOEnZb"><div class=3D"h5"><br></div></div></blockq=
uote><div><br>They will consume normal memory, right now you can see that o=
n heavy load hugue chunk of your system memory disappear, it&#39;s the gpu =
driver that is using it, it get mapped into gpu address space and from gpu =
unit pov it&#39;s just like any other memory (ie vram or sram looks the sam=
e to the gpu acceleration core, sram is just slower).<br>
<br>Cheers<br>Jerome<br></div></div>

--047d7b5db86c7453b104da216565--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
