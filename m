Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 8568C6B0005
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 09:32:47 -0400 (EDT)
Received: by mail-qe0-f50.google.com with SMTP id a11so1533056qen.9
        for <linux-mm@kvack.org>; Fri, 12 Apr 2013 06:32:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51679F46.7030901@gmail.com>
References: <5114DF05.7070702@mellanox.com>
	<CANN689Ff6vSu4ZvHek4J4EMzFG7EjF-Ej48hJKV_4SrLoj+mCA@mail.gmail.com>
	<CAH3drwaACy5KFv_2ozEe35u1Jpxs0f6msKoW=3_0nrWZpJnO4w@mail.gmail.com>
	<5163D119.80603@gmail.com>
	<20130409142156.GA1909@gmail.com>
	<5164C365.70302@gmail.com>
	<20130410204507.GA3958@gmail.com>
	<5166310D.4020100@gmail.com>
	<20130411183828.GA6696@gmail.com>
	<51676941.3050802@gmail.com>
	<CAH3drwYee1mKMPcT5QJNsaGGEvJHNTPFEvndpvS+HkeuwwAYmg@mail.gmail.com>
	<51679F46.7030901@gmail.com>
Date: Fri, 12 Apr 2013 09:32:46 -0400
Message-ID: <CAH3drwaC8TgSGfhPxAe-6VVCMPquJ0dG+Fu_6RDr7B_tH91-Hg@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Hardware initiated paging of user process pages,
 hardware access to the CPU page tables of user processes
From: Jerome Glisse <j.glisse@gmail.com>
Content-Type: multipart/alternative; boundary=f46d0447a18d46aeec04da29f009
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Michel Lespinasse <walken@google.com>, Shachar Raindel <raindel@mellanox.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Roland Dreier <roland@purestorage.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Liran Liss <liranl@mellanox.com>

--f46d0447a18d46aeec04da29f009
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Apr 12, 2013 at 1:44 AM, Simon Jeons <simon.jeons@gmail.com> wrote:

>  Hi Jerome,
>
> On 04/12/2013 10:57 AM, Jerome Glisse wrote:
>
> On Thu, Apr 11, 2013 at 9:54 PM, Simon Jeons <simon.jeons@gmail.com>wrote:
>
>> Hi Jerome,
>>
>> On 04/12/2013 02:38 AM, Jerome Glisse wrote:
>>
>>> On Thu, Apr 11, 2013 at 11:42:05AM +0800, Simon Jeons wrote:
>>>
>>>> Hi Jerome,
>>>> On 04/11/2013 04:45 AM, Jerome Glisse wrote:
>>>>
>>>>> On Wed, Apr 10, 2013 at 09:41:57AM +0800, Simon Jeons wrote:
>>>>>
>>>>>> Hi Jerome,
>>>>>> On 04/09/2013 10:21 PM, Jerome Glisse wrote:
>>>>>>
>>>>>>> On Tue, Apr 09, 2013 at 04:28:09PM +0800, Simon Jeons wrote:
>>>>>>>
>>>>>>>> Hi Jerome,
>>>>>>>> On 02/10/2013 12:29 AM, Jerome Glisse wrote:
>>>>>>>>
>>>>>>>>> On Sat, Feb 9, 2013 at 1:05 AM, Michel Lespinasse <
>>>>>>>>> walken@google.com> wrote:
>>>>>>>>>
>>>>>>>>>> On Fri, Feb 8, 2013 at 3:18 AM, Shachar Raindel <
>>>>>>>>>> raindel@mellanox.com> wrote:
>>>>>>>>>>
>>>>>>>>>>> Hi,
>>>>>>>>>>>
>>>>>>>>>>> We would like to present a reference implementation for safely
>>>>>>>>>>> sharing
>>>>>>>>>>> memory pages from user space with the hardware, without pinning.
>>>>>>>>>>>
>>>>>>>>>>> We will be happy to hear the community feedback on our prototype
>>>>>>>>>>> implementation, and suggestions for future improvements.
>>>>>>>>>>>
>>>>>>>>>>> We would also like to discuss adding features to the core MM
>>>>>>>>>>> subsystem to
>>>>>>>>>>> assist hardware access to user memory without pinning.
>>>>>>>>>>>
>>>>>>>>>> This sounds kinda scary TBH; however I do understand the need for
>>>>>>>>>> such
>>>>>>>>>> technology.
>>>>>>>>>>
>>>>>>>>>> I think one issue is that many MM developers are insufficiently
>>>>>>>>>> aware
>>>>>>>>>> of such developments; having a technology presentation would
>>>>>>>>>> probably
>>>>>>>>>> help there; but traditionally LSF/MM sessions are more interactive
>>>>>>>>>> between developers who are already quite familiar with the
>>>>>>>>>> technology.
>>>>>>>>>> I think it would help if you could send in advance a detailed
>>>>>>>>>> presentation of the problem and the proposed solutions (and then
>>>>>>>>>> what
>>>>>>>>>> they require of the MM layer) so people can be better prepared.
>>>>>>>>>>
>>>>>>>>>> And first I'd like to ask, aren't IOMMUs supposed to already
>>>>>>>>>> largely
>>>>>>>>>> solve this problem ? (probably a dumb question, but that just
>>>>>>>>>> tells
>>>>>>>>>> you how much you need to explain :)
>>>>>>>>>>
>>>>>>>>> For GPU the motivation is three fold. With the advance of GPU
>>>>>>>>> compute
>>>>>>>>> and also with newer graphic program we see a massive increase in
>>>>>>>>> GPU
>>>>>>>>> memory consumption. We easily can reach buffer that are bigger than
>>>>>>>>> 1gbytes. So the first motivation is to directly use the memory the
>>>>>>>>> user allocated through malloc in the GPU this avoid copying
>>>>>>>>> 1gbytes of
>>>>>>>>> data with the cpu to the gpu buffer. The second and mostly
>>>>>>>>> important
>>>>>>>>> to GPU compute is the use of GPU seamlessly with the CPU, in order
>>>>>>>>> to
>>>>>>>>> achieve this you want the programmer to have a single address
>>>>>>>>> space on
>>>>>>>>> the CPU and GPU. So that the same address point to the same object
>>>>>>>>> on
>>>>>>>>> GPU as on the CPU. This would also be a tremendous cleaner design
>>>>>>>>> from
>>>>>>>>> driver point of view toward memory management.
>>>>>>>>>
>>>>>>>>> And last, the most important, with such big buffer (>1gbytes) the
>>>>>>>>> memory pinning is becoming way to expensive and also drastically
>>>>>>>>> reduce the freedom of the mm to free page for other process. Most
>>>>>>>>> of
>>>>>>>>> the time a small window (every thing is relative the window can be
>>>>>>>>> >
>>>>>>>>> 100mbytes not so small :)) of the object will be in use by the
>>>>>>>>> hardware. The hardware pagefault support would avoid the necessity
>>>>>>>>> to
>>>>>>>>>
>>>>>>>> What's the meaning of hardware pagefault?
>>>>>>>>
>>>>>>> It's a PCIE extension (well it's a combination of extension that
>>>>>>> allow
>>>>>>> that see http://www.pcisig.com/specifications/iov/ats/). Idea is
>>>>>>> that the
>>>>>>> iommu can trigger a regular pagefault inside a process address space
>>>>>>> on
>>>>>>> behalf of the hardware. The only iommu supporting that right now is
>>>>>>> the
>>>>>>> AMD iommu v2 that you find on recent AMD platform.
>>>>>>>
>>>>>> Why need hardware page fault? regular page fault is trigger by cpu
>>>>>> mmu, correct?
>>>>>>
>>>>> Well here i abuse regular page fault term. Idea is that with hardware
>>>>> page
>>>>> fault you don't need to pin memory or take reference on page for
>>>>> hardware to
>>>>> use it. So that kernel can free as usual page that would otherwise
>>>>> have been
>>>>>
>>>> For the case when GPU need to pin memory, why GPU need grap the
>>>> memory of normal process instead of allocating for itself?
>>>>
>>> Pin memory is today world where gpu allocate its own memory (GB of
>>> memory)
>>> that disappear from kernel control ie kernel can no longer reclaim this
>>> memory it's lost memory (i had complain about that already from user than
>>> saw GB of memory vanish and couldn't understand why the GPU was using so
>>> much).
>>>
>>> Tomorrow world we want gpu to be able to access memory that the
>>> application
>>> allocated through a simple malloc and we want the kernel to be able to
>>> recycly any page at any time because of memory pressure or because kernel
>>> decide to do so.
>>>
>>> That's just what we want to do. To achieve so we are getting hw that can
>>> do
>>> pagefault. No change to kernel core mm code (some improvement might be
>>> made).
>>>
>>
>>  The memory disappear since you have a reference(gup) against it,
>> correct? Tomorrow world you want the page fault trigger through iommu
>> driver that call get_user_pages, it also will take a reference(since gup is
>> called), isn't it? Anyway, assume tomorrow world doesn't take a reference,
>> we don't need care page which used by GPU is reclaimed?
>>
>>
> Right now code use gup because it's convenient but it drop the reference
> right after the fault. So reference is hold only for short period of time.
>
>
> Are you sure gup will drop the reference right after the fault? I redig
> the codes and fail verify it. Could you point out to me?
>
>
In amd_iommu_v2.c:do_fault get_user_pages followed by put_page


Cheers,
Jerome

--f46d0447a18d46aeec04da29f009
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div class=3D"gmail_quote">On Fri, Apr 12, 2013 at 1:44 AM, Simon Jeons <sp=
an dir=3D"ltr">&lt;<a href=3D"mailto:simon.jeons@gmail.com" target=3D"_blan=
k">simon.jeons@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex">

 =20
   =20
 =20
  <div bgcolor=3D"#FFFFFF" text=3D"#000000">
    <div>Hi Jerome,<div><div class=3D"h5"><br>
      On 04/12/2013 10:57 AM, Jerome Glisse wrote:<br>
    </div></div></div><div><div class=3D"h5">
    <blockquote type=3D"cite">On Thu, Apr 11, 2013 at 9:54 PM, Simon Jeons =
<span dir=3D"ltr">&lt;<a href=3D"mailto:simon.jeons@gmail.com" target=3D"_b=
lank">simon.jeons@gmail.com</a>&gt;</span>
      wrote:<br>
      <div class=3D"gmail_quote">
        <blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border=
-left:1px #ccc solid;padding-left:1ex">
          Hi Jerome,
          <div>
            <div><br>
              On 04/12/2013 02:38 AM, Jerome Glisse wrote:<br>
              <blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex">
                On Thu, Apr 11, 2013 at 11:42:05AM +0800, Simon Jeons
                wrote:<br>
                <blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8e=
x;border-left:1px #ccc solid;padding-left:1ex">
                  Hi Jerome,<br>
                  On 04/11/2013 04:45 AM, Jerome Glisse wrote:<br>
                  <blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .=
8ex;border-left:1px #ccc solid;padding-left:1ex">
                    On Wed, Apr 10, 2013 at 09:41:57AM +0800, Simon
                    Jeons wrote:<br>
                    <blockquote class=3D"gmail_quote" style=3D"margin:0 0 0=
 .8ex;border-left:1px #ccc solid;padding-left:1ex">
                      Hi Jerome,<br>
                      On 04/09/2013 10:21 PM, Jerome Glisse wrote:<br>
                      <blockquote class=3D"gmail_quote" style=3D"margin:0 0=
 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
                        On Tue, Apr 09, 2013 at 04:28:09PM +0800, Simon
                        Jeons wrote:<br>
                        <blockquote class=3D"gmail_quote" style=3D"margin:0=
 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
                          Hi Jerome,<br>
                          On 02/10/2013 12:29 AM, Jerome Glisse wrote:<br>
                          <blockquote class=3D"gmail_quote" style=3D"margin=
:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
                            On Sat, Feb 9, 2013 at 1:05 AM, Michel
                            Lespinasse &lt;<a href=3D"mailto:walken@google.=
com" target=3D"_blank">walken@google.com</a>&gt;
                            wrote:<br>
                            <blockquote class=3D"gmail_quote" style=3D"marg=
in:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
                              On Fri, Feb 8, 2013 at 3:18 AM, Shachar
                              Raindel &lt;<a href=3D"mailto:raindel@mellano=
x.com" target=3D"_blank">raindel@mellanox.com</a>&gt;
                              wrote:<br>
                              <blockquote class=3D"gmail_quote" style=3D"ma=
rgin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
                                Hi,<br>
                                <br>
                                We would like to present a reference
                                implementation for safely sharing<br>
                                memory pages from user space with the
                                hardware, without pinning.<br>
                                <br>
                                We will be happy to hear the community
                                feedback on our prototype<br>
                                implementation, and suggestions for
                                future improvements.<br>
                                <br>
                                We would also like to discuss adding
                                features to the core MM subsystem to<br>
                                assist hardware access to user memory
                                without pinning.<br>
                              </blockquote>
                              This sounds kinda scary TBH; however I do
                              understand the need for such<br>
                              technology.<br>
                              <br>
                              I think one issue is that many MM
                              developers are insufficiently aware<br>
                              of such developments; having a technology
                              presentation would probably<br>
                              help there; but traditionally LSF/MM
                              sessions are more interactive<br>
                              between developers who are already quite
                              familiar with the technology.<br>
                              I think it would help if you could send in
                              advance a detailed<br>
                              presentation of the problem and the
                              proposed solutions (and then what<br>
                              they require of the MM layer) so people
                              can be better prepared.<br>
                              <br>
                              And first I&#39;d like to ask, aren&#39;t IOM=
MUs
                              supposed to already largely<br>
                              solve this problem ? (probably a dumb
                              question, but that just tells<br>
                              you how much you need to explain :)<br>
                            </blockquote>
                            For GPU the motivation is three fold. With
                            the advance of GPU compute<br>
                            and also with newer graphic program we see a
                            massive increase in GPU<br>
                            memory consumption. We easily can reach
                            buffer that are bigger than<br>
                            1gbytes. So the first motivation is to
                            directly use the memory the<br>
                            user allocated through malloc in the GPU
                            this avoid copying 1gbytes of<br>
                            data with the cpu to the gpu buffer. The
                            second and mostly important<br>
                            to GPU compute is the use of GPU seamlessly
                            with the CPU, in order to<br>
                            achieve this you want the programmer to have
                            a single address space on<br>
                            the CPU and GPU. So that the same address
                            point to the same object on<br>
                            GPU as on the CPU. This would also be a
                            tremendous cleaner design from<br>
                            driver point of view toward memory
                            management.<br>
                            <br>
                            And last, the most important, with such big
                            buffer (&gt;1gbytes) the<br>
                            memory pinning is becoming way to expensive
                            and also drastically<br>
                            reduce the freedom of the mm to free page
                            for other process. Most of<br>
                            the time a small window (every thing is
                            relative the window can be &gt;<br>
                            100mbytes not so small :)) of the object
                            will be in use by the<br>
                            hardware. The hardware pagefault support
                            would avoid the necessity to<br>
                          </blockquote>
                          What&#39;s the meaning of hardware pagefault?<br>
                        </blockquote>
                        It&#39;s a PCIE extension (well it&#39;s a combinat=
ion
                        of extension that allow<br>
                        that see <a href=3D"http://www.pcisig.com/specifica=
tions/iov/ats/" target=3D"_blank">http://www.pcisig.com/specifications/iov/=
ats/</a>).
                        Idea is that the<br>
                        iommu can trigger a regular pagefault inside a
                        process address space on<br>
                        behalf of the hardware. The only iommu
                        supporting that right now is the<br>
                        AMD iommu v2 that you find on recent AMD
                        platform.<br>
                      </blockquote>
                      Why need hardware page fault? regular page fault
                      is trigger by cpu<br>
                      mmu, correct?<br>
                    </blockquote>
                    Well here i abuse regular page fault term. Idea is
                    that with hardware page<br>
                    fault you don&#39;t need to pin memory or take referenc=
e
                    on page for hardware to<br>
                    use it. So that kernel can free as usual page that
                    would otherwise have been<br>
                  </blockquote>
                  For the case when GPU need to pin memory, why GPU need
                  grap the<br>
                  memory of normal process instead of allocating for
                  itself?<br>
                </blockquote>
                Pin memory is today world where gpu allocate its own
                memory (GB of memory)<br>
                that disappear from kernel control ie kernel can no
                longer reclaim this<br>
                memory it&#39;s lost memory (i had complain about that
                already from user than<br>
                saw GB of memory vanish and couldn&#39;t understand why the
                GPU was using so<br>
                much).<br>
                <br>
                Tomorrow world we want gpu to be able to access memory
                that the application<br>
                allocated through a simple malloc and we want the kernel
                to be able to<br>
                recycly any page at any time because of memory pressure
                or because kernel<br>
                decide to do so.<br>
                <br>
                That&#39;s just what we want to do. To achieve so we are
                getting hw that can do<br>
                pagefault. No change to kernel core mm code (some
                improvement might be made).<br>
              </blockquote>
              <br>
            </div>
          </div>
          The memory disappear since you have a reference(gup) against
          it, correct? Tomorrow world you want the page fault trigger
          through iommu driver that call get_user_pages, it also will
          take a reference(since gup is called), isn&#39;t it? Anyway,
          assume tomorrow world doesn&#39;t take a reference, we don&#39;t =
need
          care page which used by GPU is reclaimed?
          <div>
            <div><br>
            </div>
          </div>
        </blockquote>
        <div><br>
          Right now code use gup because it&#39;s convenient but it drop th=
e
          reference right after the fault. So reference is hold only for
          short period of time.<br>
        </div>
      </div>
    </blockquote>
    <br></div></div>
    Are you sure gup will drop the reference right after the fault? I
    redig the codes and fail verify it. Could you point out to me?<div clas=
s=3D"im"><br></div></div></blockquote><div>=A0</div><div>In amd_iommu_v2.c:=
do_fault get_user_pages followed by put_page<br>=A0<br>=A0</div>Cheers,<br>=
Jerome<br>
</div>

--f46d0447a18d46aeec04da29f009--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
