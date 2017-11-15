Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B51F6B0038
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 14:17:58 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id n61so21399349qte.3
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 11:17:58 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b37sor2366220qtc.62.2017.11.15.11.17.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Nov 2017 11:17:57 -0800 (PST)
Subject: Re: [PATCH] mm, meminit: Serially initialise deferred memory if
 trace_buf_size is specified
References: <20171115085556.fla7upm3nkydlflp@techsingularity.net>
 <20171115115559.rjb5hy6d6332jgjj@dhcp22.suse.cz>
 <20171115141329.ieoqvyoavmv6gnea@techsingularity.net>
 <20171115142816.zxdgkad3ch2bih6d@dhcp22.suse.cz>
 <20171115144314.xwdi2sbcn6m6lqdo@techsingularity.net>
 <20171115145716.w34jaez5ljb3fssn@dhcp22.suse.cz>
From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Message-ID: <06a33f82-7f83-7721-50ec-87bf1370c3d4@gmail.com>
Date: Wed, 15 Nov 2017 14:17:52 -0500
MIME-Version: 1.0
In-Reply-To: <20171115145716.w34jaez5ljb3fssn@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, koki.sanagi@us.fujitsu.com, yasu.isimatu@gmail.com

Hi Michal and Mel,

To reproduce the issue, I specified the large trace buffer. The issue also occurs with
trace_buf_size=12M and movable_node on 4.14.0.

In my system, there are 384 CPUs and 8 nodes. So when not using movable_node boot option,
kernel can use about 16GB memory for trace buffer. So Kernel boots up with trace_buf_size=12M.
But when using movable_node, 6 nodes are managed as MOVABLE_ZONE in my system and kernel can
use only about 4GB memory for trace buffer. So memory allocation failure of trace buffer occurs
with trace_buf_size=12M and movable_node.

I don't know you still think 12M is large. But the latest Fujitsu server supports 448 CPUs.
The issue may occur with trace_buf_size=10M on the system. Additionally the number of CPU
in a server is increasing year by year. So the issue will occurs even if we don't specify
large trace buffer.

Thanks,
Yasuaki Ishimatsu

On 11/15/2017 09:57 AM, Michal Hocko wrote:
> On Wed 15-11-17 14:43:14, Mel Gorman wrote:
>> On Wed, Nov 15, 2017 at 03:28:16PM +0100, Michal Hocko wrote:
>>> On Wed 15-11-17 14:13:29, Mel Gorman wrote:
>>> [...]
>>>> I doubt anyone well. Even the original reporter appeared to pick that
>>>> particular value just to trigger the OOM.
>>>
>>> Then why do we care at all? The trace buffer size can be configured from
>>> the userspace if it is not sufficiently large IIRC.
>>>
>>
>> I guess there is the potential that the trace buffer needs to be large
>> enough early on in boot but I'm not sure why it would need to be that large
>> to be honest. Bottom line, it's fairly trivial to just serialise meminit
>> in the event that it's resized from command line. I'm also ok with just
>> leaving this is as a "don't set the buffer that large"
> 
> I would be reluctant to touch the code just because of insane kernel
> command line option.
> 
> That being said, I will not object or block the patch it just seems
> unnecessary for most reasonable setups I can think of. If there is a
> legitimate usage of such a large trace buffer then I wouldn't oppose.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
