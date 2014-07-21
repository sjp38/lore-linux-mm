Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB086B0035
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 17:56:30 -0400 (EDT)
Received: by mail-qa0-f53.google.com with SMTP id v10so5701724qac.26
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 14:56:29 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1blp0186.outbound.protection.outlook.com. [207.46.163.186])
        by mx.google.com with ESMTPS id j21si28363081qgd.115.2014.07.21.14.56.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Jul 2014 14:56:28 -0700 (PDT)
Message-ID: <53CD8C7D.9010106@amd.com>
Date: Tue, 22 Jul 2014 00:56:13 +0300
From: Oded Gabbay <oded.gabbay@amd.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
References: <20140720174652.GE3068@gmail.com> <53CD0961.4070505@amd.com>
 <53CD17FD.3000908@vodafone.de> <53CD1FB6.1000602@amd.com>
 <20140721155437.GA4519@gmail.com> <53CD5122.5040804@amd.com>
 <20140721181433.GA5196@gmail.com> <53CD5DBC.7010301@amd.com>
 <20140721185940.GA5278@gmail.com> <53CD68BF.4020308@amd.com>
 <20140721192837.GC5278@gmail.com>
In-Reply-To: <20140721192837.GC5278@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Andrew Lewycky <Andrew.Lewycky@amd.com>, =?UTF-8?B?TWljaGVsIETDpG56ZXI=?= <michel.daenzer@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>, Evgeny
 Pinchuk <Evgeny.Pinchuk@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, Andrew Morton <akpm@linux-foundation.org>

On 21/07/14 22:28, Jerome Glisse wrote:
> On Mon, Jul 21, 2014 at 10:23:43PM +0300, Oded Gabbay wrote:
>> On 21/07/14 21:59, Jerome Glisse wrote:
>>> On Mon, Jul 21, 2014 at 09:36:44PM +0300, Oded Gabbay wrote:
>>>> On 21/07/14 21:14, Jerome Glisse wrote:
>>>>> On Mon, Jul 21, 2014 at 08:42:58PM +0300, Oded Gabbay wrote:
>>>>>> On 21/07/14 18:54, Jerome Glisse wrote:
>>>>>>> On Mon, Jul 21, 2014 at 05:12:06PM +0300, Oded Gabbay wrote:
>>>>>>>> On 21/07/14 16:39, Christian K=C3=B6nig wrote:
>>>>>>>>> Am 21.07.2014 14:36, schrieb Oded Gabbay:
>>>>>>>>>> On 20/07/14 20:46, Jerome Glisse wrote:
>>>>>>>>>>> On Thu, Jul 17, 2014 at 04:57:25PM +0300, Oded Gabbay wrote:
>>>>>>>>>>>> Forgot to cc mailing list on cover letter. Sorry.
>>>>>>>>>>>>
>>>>>>>>>>>> As a continuation to the existing discussion, here is a v2 p=
atch series
>>>>>>>>>>>> restructured with a cleaner history and no totally-different=
-early-versions
>>>>>>>>>>>> of the code.
>>>>>>>>>>>>
>>>>>>>>>>>> Instead of 83 patches, there are now a total of 25 patches, =
where 5 of them
>>>>>>>>>>>> are modifications to radeon driver and 18 of them include on=
ly amdkfd code.
>>>>>>>>>>>> There is no code going away or even modified between patches=
, only added.
>>>>>>>>>>>>
>>>>>>>>>>>> The driver was renamed from radeon_kfd to amdkfd and moved t=
o reside under
>>>>>>>>>>>> drm/radeon/amdkfd. This move was done to emphasize the fact =
that this driver
>>>>>>>>>>>> is an AMD-only driver at this point. Having said that, we do=
 foresee a
>>>>>>>>>>>> generic hsa framework being implemented in the future and in=
 that case, we
>>>>>>>>>>>> will adjust amdkfd to work within that framework.
>>>>>>>>>>>>
>>>>>>>>>>>> As the amdkfd driver should support multiple AMD gfx drivers=
, we want to
>>>>>>>>>>>> keep it as a seperate driver from radeon. Therefore, the amd=
kfd code is
>>>>>>>>>>>> contained in its own folder. The amdkfd folder was put under=
 the radeon
>>>>>>>>>>>> folder because the only AMD gfx driver in the Linux kernel a=
t this point
>>>>>>>>>>>> is the radeon driver. Having said that, we will probably nee=
d to move it
>>>>>>>>>>>> (maybe to be directly under drm) after we integrate with add=
itional AMD gfx
>>>>>>>>>>>> drivers.
>>>>>>>>>>>>
>>>>>>>>>>>> For people who like to review using git, the v2 patch set is=
 located at:
>>>>>>>>>>>> http://cgit.freedesktop.org/~gabbayo/linux/log/?h=3Dkfd-next=
-3.17-v2
>>>>>>>>>>>>
>>>>>>>>>>>> Written by Oded Gabbayh <oded.gabbay@amd.com>
>>>>>>>>>>>
>>>>>>>>>>> So quick comments before i finish going over all patches. The=
re is many
>>>>>>>>>>> things that need more documentation espacialy as of right now=
 there is
>>>>>>>>>>> no userspace i can go look at.
>>>>>>>>>> So quick comments on some of your questions but first of all, =
thanks for the
>>>>>>>>>> time you dedicated to review the code.
>>>>>>>>>>>
>>>>>>>>>>> There few show stopper, biggest one is gpu memory pinning thi=
s is a big
>>>>>>>>>>> no, that would need serious arguments for any hope of convinc=
ing me on
>>>>>>>>>>> that side.
>>>>>>>>>> We only do gpu memory pinning for kernel objects. There are no=
 userspace
>>>>>>>>>> objects that are pinned on the gpu memory in our driver. If th=
at is the case,
>>>>>>>>>> is it still a show stopper ?
>>>>>>>>>>
>>>>>>>>>> The kernel objects are:
>>>>>>>>>> - pipelines (4 per device)
>>>>>>>>>> - mqd per hiq (only 1 per device)
>>>>>>>>>> - mqd per userspace queue. On KV, we support up to 1K queues p=
er process, for
>>>>>>>>>> a total of 512K queues. Each mqd is 151 bytes, but the allocat=
ion is done in
>>>>>>>>>> 256 alignment. So total *possible* memory is 128MB
>>>>>>>>>> - kernel queue (only 1 per device)
>>>>>>>>>> - fence address for kernel queue
>>>>>>>>>> - runlists for the CP (1 or 2 per device)
>>>>>>>>>
>>>>>>>>> The main questions here are if it's avoid able to pin down the =
memory and if the
>>>>>>>>> memory is pinned down at driver load, by request from userspace=
 or by anything
>>>>>>>>> else.
>>>>>>>>>
>>>>>>>>> As far as I can see only the "mqd per userspace queue" might be=
 a bit
>>>>>>>>> questionable, everything else sounds reasonable.
>>>>>>>>>
>>>>>>>>> Christian.
>>>>>>>>
>>>>>>>> Most of the pin downs are done on device initialization.
>>>>>>>> The "mqd per userspace" is done per userspace queue creation. Ho=
wever, as I
>>>>>>>> said, it has an upper limit of 128MB on KV, and considering the =
2G local
>>>>>>>> memory, I think it is OK.
>>>>>>>> The runlists are also done on userspace queue creation/deletion,=
 but we only
>>>>>>>> have 1 or 2 runlists per device, so it is not that bad.
>>>>>>>
>>>>>>> 2G local memory ? You can not assume anything on userside configu=
ration some
>>>>>>> one might build an hsa computer with 512M and still expect a func=
tioning
>>>>>>> desktop.
>>>>>> First of all, I'm only considering Kaveri computer, not "hsa" comp=
uter.
>>>>>> Second, I would imagine we can build some protection around it, li=
ke
>>>>>> checking total local memory and limit number of queues based on so=
me
>>>>>> percentage of that total local memory. So, if someone will have on=
ly
>>>>>> 512M, he will be able to open less queues.
>>>>>>
>>>>>>
>>>>>>>
>>>>>>> I need to go look into what all this mqd is for, what it does and=
 what it is
>>>>>>> about. But pinning is really bad and this is an issue with usersp=
ace command
>>>>>>> scheduling an issue that obviously AMD fails to take into account=
 in design
>>>>>>> phase.
>>>>>> Maybe, but that is the H/W design non-the-less. We can't very well
>>>>>> change the H/W.
>>>>>
>>>>> You can not change the hardware but it is not an excuse to allow ba=
d design to
>>>>> sneak in software to work around that. So i would rather penalize b=
ad hardware
>>>>> design and have command submission in the kernel, until AMD fix its=
 hardware to
>>>>> allow proper scheduling by the kernel and proper control by the ker=
nel.=20
>>>> I'm sorry but I do *not* think this is a bad design. S/W scheduling =
in
>>>> the kernel can not, IMO, scale well to 100K queues and 10K processes=
.
>>>
>>> I am not advocating for having kernel decide down to the very last de=
tails. I am
>>> advocating for kernel being able to preempt at any time and be able t=
o decrease
>>> or increase user queue priority so overall kernel is in charge of res=
ources
>>> management and it can handle rogue client in proper fashion.
>>>
>>>>
>>>>> Because really where we want to go is having GPU closer to a CPU in=
 term of scheduling
>>>>> capacity and once we get there we want the kernel to always be able=
 to take over
>>>>> and do whatever it wants behind process back.
>>>> Who do you refer to when you say "we" ? AFAIK, the hw scheduling
>>>> direction is where AMD is now and where it is heading in the future.
>>>> That doesn't preclude the option to allow the kernel to take over an=
d do
>>>> what he wants. I agree that in KV we have a problem where we can't d=
o a
>>>> mid-wave preemption, so theoretically, a long running compute kernel=
 can
>>>> make things messy, but in Carrizo, we will have this ability. Having
>>>> said that, it will only be through the CP H/W scheduling. So AMD is
>>>> _not_ going to abandon H/W scheduling. You can dislike it, but this =
is
>>>> the situation.
>>>
>>> We was for the overall Linux community but maybe i should not pretend=
 to talk
>>> for anyone interested in having a common standard.
>>>
>>> My point is that current hardware do not have approriate hardware sup=
port for
>>> preemption hence, current hardware should use ioctl to schedule job a=
nd AMD
>>> should think a bit more on commiting to a design and handwaving any h=
ardware
>>> short coming as something that can be work around in the software. Th=
e pinning
>>> thing is broken by design, only way to work around it is through kern=
el cmd
>>> queue scheduling that's a fact.
>>
>>>
>>> Once hardware support proper preemption and allows to move around/evi=
ct buffer
>>> use on behalf of userspace command queue then we can allow userspace =
scheduling
>>> but until then my personnal opinion is that it should not be allowed =
and that
>>> people will have to pay the ioctl price which i proved to be small, b=
ecause
>>> really if you 100K queue each with one job, i would not expect that a=
ll those
>>> 100K job will complete in less time than it takes to execute an ioctl=
 ie by
>>> even if you do not have the ioctl delay what ever you schedule will h=
ave to
>>> wait on previously submited jobs.
>>
>> But Jerome, the core problem still remains in effect, even with your
>> suggestion. If an application, either via userspace queue or via ioctl=
,
>> submits a long-running kernel, than the CPU in general can't stop the
>> GPU from running it. And if that kernel does while(1); than that's it,
>> game's over, and no matter how you submitted the work. So I don't real=
ly
>> see the big advantage in your proposal. Only in CZ we can stop this wa=
ve
>> (by CP H/W scheduling only). What are you saying is basically I won't
>> allow people to use compute on Linux KV system because it _may_ get th=
e
>> system stuck.
>>
>> So even if I really wanted to, and I may agree with you theoretically =
on
>> that, I can't fulfill your desire to make the "kernel being able to
>> preempt at any time and be able to decrease or increase user queue
>> priority so overall kernel is in charge of resources management and it
>> can handle rogue client in proper fashion". Not in KV, and I guess not
>> in CZ as well.
>>
>> 	Oded
>=20
> I do understand that but using kernel ioctl provide the same kind of co=
ntrol
> as we have now ie we can bind/unbind buffer on per command buffer submi=
ssion
> basis, just like with current graphic or compute stuff.
>=20
> Yes current graphic and compute stuff can launch a while and never retu=
rn back
> and yes currently we have nothing against that but we should and soluti=
on would
> be simple just kill the gpu thread.
>=20
OK, so in that case, the kernel can simple unmap all the queues by
simply writing an UNMAP_QUEUES packet to the HIQ. Even if the queues are
userspace, they will not be mapped to the internal CP scheduler.
Does that satisfy the kernel control level you want ?

	Oded
>>
>>>
>>>>>
>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>> It might be better to add a drivers/gpu/drm/amd directory and=
 add common
>>>>>>>>>>> stuff there.
>>>>>>>>>>>
>>>>>>>>>>> Given that this is not intended to be final HSA api AFAICT th=
en i would
>>>>>>>>>>> say this far better to avoid the whole kfd module and add ioc=
tl to radeon.
>>>>>>>>>>> This would avoid crazy communication btw radeon and kfd.
>>>>>>>>>>>
>>>>>>>>>>> The whole aperture business needs some serious explanation. E=
specialy as
>>>>>>>>>>> you want to use userspace address there is nothing to prevent=
 userspace
>>>>>>>>>>> program from allocating things at address you reserve for lds=
, scratch,
>>>>>>>>>>> ... only sane way would be to move those lds, scratch inside =
the virtual
>>>>>>>>>>> address reserved for kernel (see kernel memory map).
>>>>>>>>>>>
>>>>>>>>>>> The whole business of locking performance counter for exclusi=
ve per process
>>>>>>>>>>> access is a big NO. Which leads me to the questionable useful=
lness of user
>>>>>>>>>>> space command ring.
>>>>>>>>>> That's like saying: "Which leads me to the questionable useful=
ness of HSA". I
>>>>>>>>>> find it analogous to a situation where a network maintainer na=
cking a driver
>>>>>>>>>> for a network card, which is slower than a different network c=
ard. Doesn't
>>>>>>>>>> seem reasonable this situation is would happen. He would still=
 put both the
>>>>>>>>>> drivers in the kernel because people want to use the H/W and i=
ts features. So,
>>>>>>>>>> I don't think this is a valid reason to NACK the driver.
>>>>>>>
>>>>>>> Let me rephrase, drop the the performance counter ioctl and modul=
o memory pinning
>>>>>>> i see no objection. In other word, i am not NACKING whole patchse=
t i am NACKING
>>>>>>> the performance ioctl.
>>>>>>>
>>>>>>> Again this is another argument for round trip to the kernel. As i=
nside kernel you
>>>>>>> could properly do exclusive gpu counter access accross single use=
r cmd buffer
>>>>>>> execution.
>>>>>>>
>>>>>>>>>>
>>>>>>>>>>> I only see issues with that. First and foremost i would
>>>>>>>>>>> need to see solid figures that kernel ioctl or syscall has a =
higher an
>>>>>>>>>>> overhead that is measurable in any meaning full way against a=
 simple
>>>>>>>>>>> function call. I know the userspace command ring is a big mar=
keting features
>>>>>>>>>>> that please ignorant userspace programmer. But really this on=
ly brings issues
>>>>>>>>>>> and for absolutely not upside afaict.
>>>>>>>>>> Really ? You think that doing a context switch to kernel space=
, with all its
>>>>>>>>>> overhead, is _not_ more expansive than just calling a function=
 in userspace
>>>>>>>>>> which only puts a buffer on a ring and writes a doorbell ?
>>>>>>>
>>>>>>> I am saying the overhead is not that big and it probably will not=
 matter in most
>>>>>>> usecase. For instance i did wrote the most useless kernel module =
that add two
>>>>>>> number through an ioctl (http://people.freedesktop.org/~glisse/ad=
der.tar) and
>>>>>>> it takes ~0.35microseconds with ioctl while function is ~0.025mic=
roseconds so
>>>>>>> ioctl is 13 times slower.
>>>>>>>
>>>>>>> Now if there is enough data that shows that a significant percent=
age of jobs
>>>>>>> submited to the GPU will take less that 0.35microsecond then yes =
userspace
>>>>>>> scheduling does make sense. But so far all we have is handwaving =
with no data
>>>>>>> to support any facts.
>>>>>>>
>>>>>>>
>>>>>>> Now if we want to schedule from userspace than you will need to d=
o something
>>>>>>> about the pinning, something that gives control to kernel so that=
 kernel can
>>>>>>> unpin when it wants and move object when it wants no matter what =
userspace is
>>>>>>> doing.
>>>>>>>
>>>>>>>>>>>
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
