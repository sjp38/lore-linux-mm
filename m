Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id C83876B0038
	for <linux-mm@kvack.org>; Sun, 29 Mar 2015 04:02:23 -0400 (EDT)
Received: by wibg7 with SMTP id g7so69537399wib.1
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 01:02:23 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id p18si11854575wjw.18.2015.03.29.01.02.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Mar 2015 01:02:22 -0700 (PDT)
Received: by wiaa2 with SMTP id a2so84986550wia.0
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 01:02:21 -0700 (PDT)
Message-ID: <5517B18A.3050305@plexistor.com>
Date: Sun, 29 Mar 2015 11:02:18 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: Should implementations of ->direct_access be allowed to sleep?
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com> <1411677218-29146-22-git-send-email-matthew.r.wilcox@intel.com> <20150324185046.GA4994@whiteoak.sf.office.twttr.net> <20150326170918.GO4003@linux.intel.com> <20150326193224.GA28129@dastard>
In-Reply-To: <20150326193224.GA28129@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, msharbiani@twopensource.com

On 03/26/2015 09:32 PM, Dave Chinner wrote:
<>
>> I'm leaning towards the latter.  But I'm not sure what GFP flags to
>> recommend that brd use ... GFP_NOWAIT | __GFP_ZERO, perhaps?
> 
> What, so we get random IO failures under memory pressure?
> 
> I really think we should allow .direct_access to sleep. It means we
> can use existing drivers and it also allows future implementations
> that might require, say, RDMA to be performed to update a page
> before access is granted. i.e. .direct_access is the first hook into
> the persistent device at page fault time....
> 

I agree with Dave. Last I tried (couple years ago) doing any
allocation GFP_NOWAIT on FS IO paths fails really badly in all kind
of surprising ways. The Kernel is built in to that allocation pressure.

I think that ->direct_access should not be any different then
any other block-device access, ie allow to sleep.

With brd a user can make sure not to sleep if he pre-allocates
ie call ->direct_access at least once on a given offset-length.
But I would not like to even do that guaranty. ->direct_access
should be allowed to sleep.
Well written code has many ways to allow sleep yet be very low
latency. (So I do not see what we are missing)

> Cheers,
> Dave.

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
