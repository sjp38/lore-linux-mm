Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3866B006C
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:29:11 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so7965996pdj.26
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 10:29:10 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2lp0208.outbound.protection.outlook.com. [207.46.163.208])
        by mx.google.com with ESMTPS id gp1si13055470pbd.145.2014.07.21.10.29.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Jul 2014 10:29:10 -0700 (PDT)
Message-ID: <53CD4DD2.10906@amd.com>
Date: Mon, 21 Jul 2014 20:28:50 +0300
From: Oded Gabbay <oded.gabbay@amd.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
References: <53C7D645.3070607@amd.com> <20140720174652.GE3068@gmail.com>
 <53CD0961.4070505@amd.com> <53CD17FD.3000908@vodafone.de>
 <20140721152511.GW15237@phenom.ffwll.local> <20140721155851.GB4519@gmail.com>
 <20140721170546.GB15237@phenom.ffwll.local>
In-Reply-To: <20140721170546.GB15237@phenom.ffwll.local>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>, =?UTF-8?B?Q2hyaXN0aWFuIEvDtm5pZw==?= <deathsimple@vodafone.de>, David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John
 Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew
 Lewycky <Andrew.Lewycky@amd.com>, =?UTF-8?B?TWljaGVsIETDpG56ZXI=?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, Evgeny Pinchuk <Evgeny.Pinchuk@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>

On 21/07/14 20:05, Daniel Vetter wrote:
> On Mon, Jul 21, 2014 at 11:58:52AM -0400, Jerome Glisse wrote:
>> On Mon, Jul 21, 2014 at 05:25:11PM +0200, Daniel Vetter wrote:
>>> On Mon, Jul 21, 2014 at 03:39:09PM +0200, Christian K=C3=B6nig wrote:
>>>> Am 21.07.2014 14:36, schrieb Oded Gabbay:
>>>>> On 20/07/14 20:46, Jerome Glisse wrote:
>>>>>> On Thu, Jul 17, 2014 at 04:57:25PM +0300, Oded Gabbay wrote:
>>>>>>> Forgot to cc mailing list on cover letter. Sorry.
>>>>>>>
>>>>>>> As a continuation to the existing discussion, here is a v2 patch =
series
>>>>>>> restructured with a cleaner history and no
>>>>>>> totally-different-early-versions
>>>>>>> of the code.
>>>>>>>
>>>>>>> Instead of 83 patches, there are now a total of 25 patches, where=
 5 of
>>>>>>> them
>>>>>>> are modifications to radeon driver and 18 of them include only am=
dkfd
>>>>>>> code.
>>>>>>> There is no code going away or even modified between patches, onl=
y
>>>>>>> added.
>>>>>>>
>>>>>>> The driver was renamed from radeon_kfd to amdkfd and moved to res=
ide
>>>>>>> under
>>>>>>> drm/radeon/amdkfd. This move was done to emphasize the fact that =
this
>>>>>>> driver
>>>>>>> is an AMD-only driver at this point. Having said that, we do fore=
see a
>>>>>>> generic hsa framework being implemented in the future and in that
>>>>>>> case, we
>>>>>>> will adjust amdkfd to work within that framework.
>>>>>>>
>>>>>>> As the amdkfd driver should support multiple AMD gfx drivers, we =
want
>>>>>>> to
>>>>>>> keep it as a seperate driver from radeon. Therefore, the amdkfd c=
ode is
>>>>>>> contained in its own folder. The amdkfd folder was put under the =
radeon
>>>>>>> folder because the only AMD gfx driver in the Linux kernel at thi=
s
>>>>>>> point
>>>>>>> is the radeon driver. Having said that, we will probably need to =
move
>>>>>>> it
>>>>>>> (maybe to be directly under drm) after we integrate with addition=
al
>>>>>>> AMD gfx
>>>>>>> drivers.
>>>>>>>
>>>>>>> For people who like to review using git, the v2 patch set is loca=
ted
>>>>>>> at:
>>>>>>> http://cgit.freedesktop.org/~gabbayo/linux/log/?h=3Dkfd-next-3.17=
-v2
>>>>>>>
>>>>>>> Written by Oded Gabbayh <oded.gabbay@amd.com>
>>>>>>
>>>>>> So quick comments before i finish going over all patches. There is=
 many
>>>>>> things that need more documentation espacialy as of right now ther=
e is
>>>>>> no userspace i can go look at.
>>>>> So quick comments on some of your questions but first of all, thank=
s for
>>>>> the time you dedicated to review the code.
>>>>>>
>>>>>> There few show stopper, biggest one is gpu memory pinning this is =
a big
>>>>>> no, that would need serious arguments for any hope of convincing m=
e on
>>>>>> that side.
>>>>> We only do gpu memory pinning for kernel objects. There are no user=
space
>>>>> objects that are pinned on the gpu memory in our driver. If that is=
 the
>>>>> case, is it still a show stopper ?
>>>>>
>>>>> The kernel objects are:
>>>>> - pipelines (4 per device)
>>>>> - mqd per hiq (only 1 per device)
>>>>> - mqd per userspace queue. On KV, we support up to 1K queues per pr=
ocess,
>>>>> for a total of 512K queues. Each mqd is 151 bytes, but the allocati=
on is
>>>>> done in 256 alignment. So total *possible* memory is 128MB
>>>>> - kernel queue (only 1 per device)
>>>>> - fence address for kernel queue
>>>>> - runlists for the CP (1 or 2 per device)
>>>>
>>>> The main questions here are if it's avoid able to pin down the memor=
y and if
>>>> the memory is pinned down at driver load, by request from userspace =
or by
>>>> anything else.
>>>>
>>>> As far as I can see only the "mqd per userspace queue" might be a bi=
t
>>>> questionable, everything else sounds reasonable.
>>>
>>> Aside, i915 perspective again (i.e. how we solved this): When schedul=
ing
>>> away from contexts we unpin them and put them into the lru. And in th=
e
>>> shrinker we have a last-ditch callback to switch to a default context
>>> (since you can't ever have no context once you've started) which mean=
s we
>>> can evict any context object if it's getting in the way.
>>
>> So Intel hardware report through some interrupt or some channel when i=
t is
>> not using a context ? ie kernel side get notification when some user c=
ontext
>> is done executing ?
>=20
> Yes, as long as we do the scheduling with the cpu we get interrupts for
> context switches. The mechanic is already published in the execlist
> patches currently floating around. We get a special context switch
> interrupt.
>=20
> But we have this unpin logic already on the current code where we switc=
h
> contexts through in-line cs commands from the kernel. There we obviousl=
y
> use the normal batch completion events.
>=20
>> The issue with radeon hardware AFAICT is that the hardware do not repo=
rt any
>> thing about the userspace context running ie you do not get notificati=
on when
>> a context is not use. Well AFAICT. Maybe hardware do provide that.
>=20
> I'm not sure whether we can do the same trick with the hw scheduler. Bu=
t
> then unpinning hw contexts will drain the pipeline anyway, so I guess w=
e
> can just stop feeding the hw scheduler until it runs dry. And then unpi=
n
> and evict.
So, I'm afraid but we can't do this for AMD Kaveri because:

a. The hw scheduler doesn't inform us which queues it is going to
execute next. We feed it a runlist of queues, which can be very large
(we have a test that runs 1000 queues on the same runlist, but we can
put a lot more). All the MQDs of those queues must be pinned in memory
as long as the runlist is in effect. The runlist is in effect until
either a queue is deleted or a queue is added (or something more extreme
happens, like the process terminates).

b. The hw scheduler takes care of VMID to PASID mapping. We don't
program the ATC registers manually, the internal CP does that
dynamically, so we basically have over-subscription of processes as
well. Therefore, we can't ping MQDs based on VMID binding.

I don't see AMD moving back to SW scheduling, as it doesn't scale well
with the number of processes and queues and our next gen APU will have a
lot more queues than what we have on KV

	Oded
>=20
>> Like the VMID is a limited resources so you have to dynamicly bind the=
m so
>> maybe we can only allocate pinned buffer for each VMID and then when b=
inding
>> a PASID to a VMID it also copy back pinned buffer to pasid unpinned co=
py.
>=20
> Yeah, pasid assignment will be fun. Not sure whether Jesse's patches wi=
ll
> do this already. We _do_ already have fun with ctx id assigments though
> since we move them around (and the hw id is the ggtt address afaik). So=
 we
> need to remap them already. Not sure on the details for pasid mapping,
> iirc it's a separate field somewhere in the context struct. Jesse knows
> the details.
> -Daniel
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
