Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id B48636B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 08:49:27 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id q107so1641483qgd.1
        for <linux-mm@kvack.org>; Thu, 15 May 2014 05:49:27 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTP id a4si831972qar.222.2014.05.15.05.49.27
        for <linux-mm@kvack.org>;
        Thu, 15 May 2014 05:49:27 -0700 (PDT)
Message-ID: <5374B824.2090403@fb.com>
Date: Thu, 15 May 2014 08:50:44 -0400
From: Chris Mason <clm@fb.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Sync only the requested range in msync
References: <1395961361-21307-1-git-send-email-matthew.r.wilcox@intel.com>	<20140423141115.GA31375@infradead.org>	<20140512163948.0b365598e1e4d0b06dea3bc6@linux-foundation.org> <x49y4y54xgq.fsf@segfault.boston.devel.redhat.com>
In-Reply-To: <x49y4y54xgq.fsf@segfault.boston.devel.redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, willy@linux.intel.com

On 05/13/2014 09:31 AM, Jeff Moyer wrote:
> Andrew Morton <akpm@linux-foundation.org> writes:
> 
>> On Wed, 23 Apr 2014 07:11:15 -0700 Christoph Hellwig <hch@infradead.org> wrote:
>>
>>> On Thu, Mar 27, 2014 at 07:02:41PM -0400, Matthew Wilcox wrote:
>>>> [untested.  posted because it keeps coming up at lsfmm/collab]
>>>>
>>>> msync() currently syncs more than POSIX requires or BSD or Solaris
>>>> implement.  It is supposed to be equivalent to fdatasync(), not fsync(),
>>>> and it is only supposed to sync the portion of the file that overlaps
>>>> the range passed to msync.
>>>>
>>>> If the VMA is non-linear, fall back to syncing the entire file, but we
>>>> still optimise to only fdatasync() the entire file, not the full fsync().
>>>>
>>>> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
>>>
>>> Looks good,
>>>
>>> Reviewed-by: Christoph Hellwig <hch@lst.de>
>>
>> I worry that if there are people who are relying on the current
>> behaviour (knowingly or not!) then this patch will put their data at
>> risk and nobody will ever know.  Until that data gets lost, that is.
>> At some level of cautiousness, this is one of those things we can never
>> fix.
>>
>> I suppose we could add an msync2() syscall with the new behaviour so
>> people can migrate over.  That would be very cheap to do.
>>
>> It's hard to know what's the right thing to do here.
> 
> FWIW, I think we should apply the patch.  Anyone using the API properly
> will not get the desired result, and it could have a negative impact on
> performance.  The man page is very explicit on what you should expect,
> here.  Anyone relying on undocumented behavior gets to keep both pieces
> when it breaks.  That said, I do understand your viewpoint, Andrew,
> especially since it's so hard to get people to sync their data at all,
> much less correctly.
> 
> Acked-by: Jeff Moyer <jmoyer@redhat.com>

Maybe we can talk someone with all of linux in a repository to grep for
msync calls that even specify a range at all?

Eric did this for 64 bit inodes a few years ago, and it wouldn't hurt to
have a little data on how common this is.

I think for msync the list will be much shorter and easier to audit.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
