Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EB87C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:51:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E0862173B
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:51:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="PnxGlUUA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E0862173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D51726B0003; Thu, 15 Aug 2019 16:51:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D01DD6B000A; Thu, 15 Aug 2019 16:51:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF0FA6B000C; Thu, 15 Aug 2019 16:51:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0230.hostedemail.com [216.40.44.230])
	by kanga.kvack.org (Postfix) with ESMTP id 9E13B6B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:51:25 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 4F57D180AD802
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:51:25 +0000 (UTC)
X-FDA: 75825857730.13.mint27_296fd5ead2743
X-HE-Tag: mint27_296fd5ead2743
X-Filterd-Recvd-Size: 14122
Received: from aserp2120.oracle.com (aserp2120.oracle.com [141.146.126.78])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:51:24 +0000 (UTC)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7FKn4OC061339;
	Thu, 15 Aug 2019 20:51:18 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=GpC+6R1lz8+JZEuMGasUscMLJA1wE7x7lhh/SRTOENY=;
 b=PnxGlUUALVdrpZbvp7Px7WPwjLC10xeCPai7tl5B/azIyyCBXBfjHb6CnawAmC1qJet5
 nF+iV4kN6deEmhqLGvQ28lumeA+Td3BbUzPYMh+YzMDV0F7eF1um1fFYlGD89a2yrFYm
 duacSYxusqHElhQx18/dv6e+/BUKG3f9ZEXwvOFkSP5VxmYFN0SsFsAwBwQJe6/G7EJm
 Xz1a1lAhMjXH78C4tI7oUnMMXkwdYCpzzLzmbrdLZTlUaj2+aByh1L+JNZtFhQ73EG82
 d//9iNoQa86F9q8fR/v9glNShz+oehJB9qj2uT7UiCaXhtFxX7tl2fzLRJbdVjAIUpiL xw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2120.oracle.com with ESMTP id 2u9nvpn7s3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 15 Aug 2019 20:51:18 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7FKlw2u057107;
	Thu, 15 Aug 2019 20:51:17 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2ucgf1f3yd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 15 Aug 2019 20:51:17 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x7FKp6bV030722;
	Thu, 15 Aug 2019 20:51:07 GMT
Received: from [10.65.149.173] (/10.65.149.173)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 15 Aug 2019 13:51:06 -0700
Subject: Re: [RFC PATCH 0/2] Add predictive memory reclamation and compaction
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net,
        dan.j.williams@intel.com, osalvador@suse.de, richard.weiyang@gmail.com,
        hannes@cmpxchg.org, arunks@codeaurora.org, rppt@linux.vnet.ibm.com,
        jgg@ziepe.ca, amir73il@gmail.com, alexander.h.duyck@linux.intel.com,
        linux-mm@kvack.org, linux-kernel-mentees@lists.linuxfoundation.org,
        linux-kernel@vger.kernel.org
References: <20190813014012.30232-1-khalid.aziz@oracle.com>
 <20190813140553.GK17933@dhcp22.suse.cz>
 <3cb0af00-f091-2f3e-d6cc-73a5171e6eda@oracle.com>
 <20190814085831.GS17933@dhcp22.suse.cz>
 <d3895804-7340-a7ae-d611-62913303e9c5@oracle.com>
 <20190815170215.GQ9477@dhcp22.suse.cz>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <2668ad2e-ee52-8c88-22c0-1952243af5a1@oracle.com>
Date: Thu, 15 Aug 2019 14:51:04 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190815170215.GQ9477@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9350 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=775
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908150198
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9350 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=829 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908150198
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/15/19 11:02 AM, Michal Hocko wrote:
> On Thu 15-08-19 10:27:26, Khalid Aziz wrote:
>> On 8/14/19 2:58 AM, Michal Hocko wrote:
>>> On Tue 13-08-19 09:20:51, Khalid Aziz wrote:
>>>> On 8/13/19 8:05 AM, Michal Hocko wrote:
>>>>> On Mon 12-08-19 19:40:10, Khalid Aziz wrote:
>>>>> [...]
>>>>>> Patch 1 adds code to maintain a sliding lookback window of (time, =
number
>>>>>> of free pages) points which can be updated continuously and adds c=
ode to
>>>>>> compute best fit line across these points. It also adds code to us=
e the
>>>>>> best fit lines to determine if kernel must start reclamation or
>>>>>> compaction.
>>>>>>
>>>>>> Patch 2 adds code to collect data points on free pages of various =
orders
>>>>>> at different points in time, uses code in patch 1 to update slidin=
g
>>>>>> lookback window with these points and kicks off reclamation or
>>>>>> compaction based upon the results it gets.
>>>>>
>>>>> An important piece of information missing in your description is wh=
y
>>>>> do we need to keep that logic in the kernel. In other words, we hav=
e
>>>>> the background reclaim that acts on a wmark range and those are tun=
able
>>>>> from the userspace. The primary point of this background reclaim is=
 to
>>>>> keep balance and prevent from direct reclaim. Why cannot you implem=
ent
>>>>> this or any other dynamic trend watching watchdog and tune watermar=
ks
>>>>> accordingly? Something similar applies to kcompactd although we mig=
ht be
>>>>> lacking a good interface.
>>>>>
>>>>
>>>> Hi Michal,
>>>>
>>>> That is a very good question. As a matter of fact the initial protot=
ype
>>>> to assess the feasibility of this approach was written in userspace =
for
>>>> a very limited application. We wrote the initial prototype to monito=
r
>>>> fragmentation and used /sys/devices/system/node/node*/compact to tri=
gger
>>>> compaction. The prototype demonstrated this approach has merits.
>>>>
>>>> The primary reason to implement this logic in the kernel is to make =
the
>>>> kernel self-tuning.
>>>
>>> What makes this particular self-tuning an universal win? In other wor=
ds
>>> there are many ways to analyze the memory pressure and feedback it ba=
ck
>>> that I can think of. It is quite likely that very specific workloads
>>> would have very specific demands there. I have seen cases where are
>>> trivial increase of min_free_kbytes to normally insane value worked
>>> really great for a DB workload because the wasted memory didn't matte=
r
>>> for example.
>>
>> Hi Michal,
>>
>> The problem is not so much as do we have enough knobs available, rathe=
r
>> how do we tweak them dynamically to avoid allocation stalls. Knobs lik=
e
>> watermarks and min_free_kbytes are set once typically and left alone.
>=20
> Does anything prevent from tuning these knobs more dynamically based on=

> already exported metrics?

Hi Michal,

The smarts for tuning these knobs can be implemented in userspace and
more knobs added to allow for what is missing today, but we get back to
the same issue as before. That does nothing to make kernel self-tuning
and adds possibly even more knobs to userspace. Something so fundamental
to kernel memory management as making free pages available when they are
needed really should be taken care of in the kernel itself. Moving it to
userspace just means the kernel is hobbled unless one installs and tunes
a userspace package correctly.

>=20
>> Allocation stalls show up even on much smaller scale than large DB or
>> cloud platforms. I have seen it on a desktop class machine running a f=
ew
>> services in the background. Desktop is running gnome3, I would lock th=
e
>> screen and come back to unlock it a day or two later. In that time mos=
t
>> of memory has been consumed by buffer/page cache. Just unlocking the
>> screen can take 30+ seconds while system reclaims pages to be able swa=
p
>> back in all the processes that were inactive so far.
>=20
> This sounds like a bug to me.

Quite possibly. I had seen that behavior with 4.17, 4.18 and 4.19
kernels. I then just moved enough tasks off of my machine to other
machines to make the problem go away. So I can't say if the problem has
persisted past 4.19.

>=20
>> It is true different workloads will have different requirements and th=
at
>> is what I am attempting to address here. Instead of tweaking the knobs=

>> statically based upon one workload requirements, I am looking at the
>> trend of memory consumption instead. A best fit line showing recent
>> trend can be quite indicative of what the workload is doing in terms o=
f
>> memory.
>=20
> Is there anything preventing from following that trend from the
> userspace and trigger background reclaim earlier to not even get to the=

> direct reclaim though?

It is possible to do that in userspace for compaction. We will need a
smaller hammer than drop_cache to do the same for reclamation. This
still makes kernel dependent upon a properly configured userspace
program for it to do something as fundamental as free page management.
That does not sound like a good situation. Allocation stalls have been a
problem for many years (I could find patch from as far back as 2002
attempting to address allocation stalls). More tuning knobs have been
temporary solution at best since workloads and storage technology keep
changing and processors keep getting faster overall.

>=20
>> For instance, a cloud server might be running a certain number
>> of instances for a few days and it can end up using any memory not use=
d
>> up by tasks, for buffer/page cache. Now the sys admin gets a request t=
o
>> launch another instance and when they try to to do that, system starts=

>> to allocate pages and soon runs out of free pages. We are now in direc=
t
>> reclaim path and it can take significant amount of time to find all fr=
ee
>> pages the new task needs. If the kernel were watching the memory
>> consumption trend instead, it could see that the trend line shows a
>> complete exhaustion of free pages or 100% fragmentation in near future=
,
>> irrespective of what the workload is.
>=20
> I am confused now. How can an unpredictable action (like sys admin
> starting a new workload) be handled by watching a memory consumption
> history trend? From the above description I would expect that the syste=
m
> would be in a balanced state for few days when a new instance is
> launched. The only reasonable thing to do then is to trigger the reclai=
m
> before the workload is spawned but then what is the actual difference
> between direct reclaim and an early reclaim?

If kernel watches trend far ahead enough, it can start
reclaiming/compacting well in advance and keep direct reclamation at bay
even if there is sudden surge of memory demand. A pathological case of
userspace suddenly demanding 100's of GB of memory in one request is
always difficult to tackle. For such cases, triggering
reclamation/compaction and waiting to launch new process until enough
free pages are available might be the only solution. A more normal case
will be a continuous stream of page allocations until a database is
fully populated or a new server instance is launched. It is like a
bucket with a hole. We can wait to start filling it until water gets
very low in it or notice that the hole at the bottom has been unplugged
and water is draining fast, so we start filling it before water gets too
low. If we have been observing how fast the bucket fills up with no leak
and how fast is the current drain, we can start filling in advance
enough that water never gets too low. That is what I referred to as
improvements to current patch, i.e. track current reclamation/compaction
rate in kswapd and kcompactd and use those rates to determine how far in
advance do we start reclaiming/compacting.

>=20
> [...]
>>> I agree on this point. Is the current set of tunning sufficient? What=

>>> would be missing if not?
>>>
>>
>> We have knob available to force compaction immediately. That is helpfu=
l
>> and in some case, sys admins have resorted to forcing compaction on al=
l
>> zones before launching a new cloud instance or loading a new database.=

>> Some admins have resorted to using /proc/sys/vm/drop_caches to force
>> buffer/page cache pages to be freed up. Either of these solutions caus=
es
>> system load to go up immediately while kswapd/kcompactd run to free up=

>> and compact pages. This is far from ideal. Other knobs available seem =
to
>> be hard to set correctly especially on servers that run mixed workload=
s
>> which results in a regular stream of customer complaints coming in abo=
ut
>> system stalling at most inopportune times.
>=20
> Then let's talk about what is missing in the existing tuning we already=

> provide. I do agree that compaction needs some love but I am under
> impression that min_free_kbytes and watermark_*_factor should give a
> decent abstraction to control the background reclaim. If that is not th=
e
> case then I am really interested on examples because I might be easily
> missing something there.

Just last week an email crossed my mailbox where an order 4 allocation
failed on a server that has 768 GB memory and had 355,000 free pages of
order 2 and lower available at the time. That allocation failure brought
down an important service and was a significant disruption.

These knobs do give some control to userspace but their values depend
upon workload and it is easy enough to set them wrong. Finding the right
value is not easy for servers that run mixed workloads. So it is not
that there are not enough knobs or we can not add more knobs. The
question is is that the right direction to go or do we make kernel
self-tuning and give it the capability to deal with these issues without
requiring sys admins to be able to determine correct values for these
knobs for every new workload.

Thanks,
Khalid


