Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2D06B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 09:15:00 -0400 (EDT)
Received: by ykdy1 with SMTP id y1so57779907ykd.2
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 06:15:00 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id k7si12913085ykd.6.2015.06.26.06.14.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 06:14:59 -0700 (PDT)
Message-ID: <558D5050.10103@citrix.com>
Date: Fri, 26 Jun 2015 14:14:56 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [PATCHv1 6/8] xen/balloon: only hotplug additional
 memory if required
References: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
	<1435252263-31952-7-git-send-email-david.vrabel@citrix.com>
	<20150625211834.GO14050@olila.local.net-space.pl>
	<558D13BF.9030907@citrix.com>
 <20150626124644.GS14050@olila.local.net-space.pl>
In-Reply-To: <20150626124644.GS14050@olila.local.net-space.pl>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <daniel.kiper@oracle.com>, David Vrabel <david.vrabel@citrix.com>
Cc: linux-mm@kvack.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org

On 26/06/15 13:46, Daniel Kiper wrote:
> On Fri, Jun 26, 2015 at 09:56:31AM +0100, David Vrabel wrote:
>> On 25/06/15 22:18, Daniel Kiper wrote:
>>> On Thu, Jun 25, 2015 at 06:11:01PM +0100, David Vrabel wrote:
>>>> Now that we track the total number of pages (included hotplugged
>>>> regions), it is easy to determine if more memory needs to be
>>>> hotplugged.
>>>>
>>>> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
>>>> ---
>>>>  drivers/xen/balloon.c |   16 +++++++++++++---
>>>>  1 file changed, 13 insertions(+), 3 deletions(-)
>>>>
>>>> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
>>>> index 960ac79..dd41da8 100644
>>>> --- a/drivers/xen/balloon.c
>>>> +++ b/drivers/xen/balloon.c
>>>> @@ -241,12 +241,22 @@ static void release_memory_resource(struct resource *resource)
>>>>   * bit set). Real size of added memory is established at page onlining stage.
>>>>   */
>>>>
>>>> -static enum bp_state reserve_additional_memory(long credit)
>>>> +static enum bp_state reserve_additional_memory(void)
>>>>  {
>>>> +	long credit;
>>>>  	struct resource *resource;
>>>>  	int nid, rc;
>>>>  	unsigned long balloon_hotplug;
>>>>
>>>> +	credit = balloon_stats.target_pages - balloon_stats.total_pages;
>>>> +
>>>> +	/*
>>>> +	 * Already hotplugged enough pages?  Wait for them to be
>>>> +	 * onlined.
>>>> +	 */
>>>
>>> Comment is wrong or at least misleading. Both values does not depend on onlining.
>>
>> If we get here and credit <=0 then the balloon is empty and we have
> 
> Right.
> 
>> already hotplugged enough sections to reach target.  We need to wait for
> 
> OK.
> 
>> userspace to online the sections that already exist.
> 
> This is not true. You do not need to online sections to reserve new
> memory region. Onlining does not change balloon_stats.target_pages
> nor balloon_stats.total_pages. You must increase balloon_stats.target_pages
> above balloon_stats.total_pages to reserve new memory region. And
> balloon_stats.target_pages increase is not related to onlining.

We don't want to keep adding sections if onlining the existing ones
would be sufficient to reach the target.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
