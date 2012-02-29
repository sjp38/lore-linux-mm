Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 2CA9A6B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:17:28 -0500 (EST)
Received: by qcsd16 with SMTP id d16so3458122qcs.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 11:17:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F4E5AF0.1080303@parallels.com>
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
	<1330383533-20711-8-git-send-email-ssouhlal@FreeBSD.org>
	<4F4CD731.60908@parallels.com>
	<CABCjUKCaJVGShRKRkvBMrz_XNVGNrcguQ1uTP8Am1fQ1Te6PWA@mail.gmail.com>
	<4F4E5AF0.1080303@parallels.com>
Date: Wed, 29 Feb 2012 11:17:27 -0800
Message-ID: <CABCjUKCgyvG+za1JpCPxCKjzB8C2RcDKZXt7Gz6soMbMD8CSHg@mail.gmail.com>
Subject: Re: [PATCH 07/10] memcg: Stop res_counter underflows.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org

On Wed, Feb 29, 2012 at 9:05 AM, Glauber Costa <glommer@parallels.com> wrot=
e:
> On 02/28/2012 08:07 PM, Suleiman Souhlal wrote:
>>
>> On Tue, Feb 28, 2012 at 5:31 AM, Glauber Costa<glommer@parallels.com>
>> =A0wrote:
>>>
>>> I don't fully understand this.
>>> To me, the whole purpose of having a cache tied to a memcg, is that we
>>> know
>>> all allocations from that particular cache should be billed to a specif=
ic
>>> memcg. So after a cache is created, and has an assigned memcg,
>>> what's the point in bypassing it to root?
>>>
>>> It smells like you're just using this to circumvent something...
>>
>>
>> In the vast majority of the cases, we will be able to account to the
>> cgroup.
>> However, there are cases when __mem_cgroup_try_charge() is not able to
>> do so, like when the task is being killed.
>> When this happens, the allocation will not get accounted to the
>> cgroup, but the slab accounting code will still think the page belongs
>> to the memcg's kmem_cache.
>> So, when we go to free the page, we assume that the page belongs to
>> the memcg and uncharge it, even though it was never charged to us in
>> the first place.
>>
>> This is the situation this patch is trying to address, by keeping a
>> counter of how much memory has been bypassed like this, and uncharging
>> from the root if we have any outstanding bypassed memory.
>>
>> Does that make sense?
>>
> Yes, but how about the following:
>
> I had a similar problem in tcp accounting, and solved that by adding
> res_counter_charge_nofail().
>
> I actually implemented something very similar to your bypass (now that I
> understand it better...) and gave up in favor of this.
>
> The tcp code has its particularities, but still, that could work okay for
> the general slab.
>
> Reason being:
>
> Consider you have a limit of X, and is currently at X-1. You bypassed a
> page.
>
> So in reality, you should fail the next allocation, but you will not -
> (unless you start considering the bypassed memory at allocation time as
> well).
>
> If you use res_counter_charge_nofail(), you will:
>
> =A01) Still proceed with the allocations that shouldn't fail - so no
> =A0 =A0difference here
> =A02) fail the normal allocations if you have "bypassed" memory filling
> =A0 =A0up your limit
> =A03) all that without coupling something alien to the res_counter API.

Ok. I'll give it a try.

Thanks!
-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
