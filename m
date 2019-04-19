Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACA5CC10F14
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 00:02:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65836217F9
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 00:02:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65836217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3AA86B0003; Thu, 18 Apr 2019 20:02:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC2276B0006; Thu, 18 Apr 2019 20:02:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D65526B0007; Thu, 18 Apr 2019 20:02:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 997C36B0003
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 20:02:33 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g1so2365279pfo.2
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 17:02:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Vk5/qZ1pVDaTet0IK9IFbMQaJ29cyy2PCNpnS+NSZsg=;
        b=VWxC541w3mgEcM4b89QdXvJ+pBsYdLrzM+4IXHh4kzSUreYCUuQcMB+SQNivySh0s8
         Bfg3n9E/rAerYhrVW8keZac8Z+ArX+9D8V1Wc7HKcDohzY/lFoKNZIKUpz1orqo698X0
         1gFgB5EZnLtgztEpgIjkoJpqVLT3zikN4Mh0TkCh4MD7BezsgY+EH6/ORFJk2q7BwIB0
         gm78eCw9W6721ao0xuKdIPUZ98j3Hq5jCUuPKkTSWWmAzLZgKUcWg83l6ml5bdE+RBIv
         hbyK//DwnF4Hg569EJVIuFElJP70LkD6MBAOKIKpZXm4fjYLfTmZmPg4LhjLp4mxTqbD
         RGzA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAVrWhjikxlaosAPTsAN/kk4nhX3jK28ah31lTS+Ohtqaswc4bOc
	r0QZZVyiVzBa7P3p6SXOml+3GtXRsxsUt1BTQF/z7JOXRoHWxrxaaN14II8w0D6nNUwWux4bOvL
	UxzTBPwNwNFjelif6w9Zga5vsKjGUMLX4lBSViMQIEKx4IfK0V3Jcrj/kxDG8zXg=
X-Received: by 2002:a62:1647:: with SMTP id 68mr534435pfw.113.1555632153190;
        Thu, 18 Apr 2019 17:02:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVcul2vgiilG7d9tEe45x7ABeHpwcH2XYqZGE+waeGMP6Mf86rLuinVrJcQkq5W5/JrvmY
X-Received: by 2002:a62:1647:: with SMTP id 68mr534334pfw.113.1555632152141;
        Thu, 18 Apr 2019 17:02:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555632152; cv=none;
        d=google.com; s=arc-20160816;
        b=Su4PQMitp2oLVdU3FvJg88Ge1xb0thrNUZ65J6wLeRIvPNaUA+2aE1lF1uqsdF688A
         VpBC2wxEUW6ZghS4cTc5eW93xRvP2sKrY4djOHTJVlox3C2WlcbLXPchZoiS7kpygda6
         f7vAkSTY80OZnxEgPn1RCKfjadj+5o8jjGPTASlqHIFib4ALFBjQmkTk3WKifZzQjBux
         xC8BuEovtV92j9e3BJF+8md4vNIM4h0IC/P4PNOvhICdAZ9S4v9PUXX37ZafOfTfzlvX
         aA8/HqABcYUYpCCH47yiePwxmpmkkgZj9vxB1JiKTMiXppj3La+dlJUufJbrumK3Fbly
         EaYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Vk5/qZ1pVDaTet0IK9IFbMQaJ29cyy2PCNpnS+NSZsg=;
        b=VnBaNYrkm1WJ3xk51Hhxokvq+WCZchFuFb5gPFMt267L6VnC0t2Pab+kPrH0KGVDqs
         1EAExR5HGtyWDBJMq0lVlkFC1nTHukvEMeJsDpnKiJd6/PPfSO0bg2HDVwkABRqshr6A
         3E6NNxGk4pe9iNOf9mJl4tf7YcyAGLBMoBZezVyBmMuXrkWRu1jhcNQEeW3as4RZQqw4
         XlPnrfkArpr8Pn5fmg69fUf2WG93qCgS81tKscAmPjhJswkoC0S8T9H8z9CjnoJPOo3g
         ierZclCLKXHRdeprGdANmmg3oy/5cLM0pqWcCyXXXBDFXNLbqvvLX8XeUvEJx7mjDiAN
         QlxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail106.syd.optusnet.com.au (mail106.syd.optusnet.com.au. [211.29.132.42])
        by mx.google.com with ESMTP id r39si3657558pld.10.2019.04.18.17.02.31
        for <linux-mm@kvack.org>;
        Thu, 18 Apr 2019 17:02:32 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.42;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-180-172-16.pa.nsw.optusnet.com.au [49.180.172.16])
	by mail106.syd.optusnet.com.au (Postfix) with ESMTPS id 202713D83FC;
	Fri, 19 Apr 2019 10:02:26 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hHGz3-0002L4-B3; Fri, 19 Apr 2019 10:02:25 +1000
Date: Fri, 19 Apr 2019 10:02:25 +1000
From: Dave Chinner <david@fromorbit.com>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>,
	Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org,
	linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v4] fs/sync.c: sync_file_range(2) may use WB_SYNC_ALL
 writeback
Message-ID: <20190419000225.GF1454@dread.disaster.area>
References: <20190409114922.30095-1-amir73il@gmail.com>
 <20190417054559.29252-1-amir73il@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190417054559.29252-1-amir73il@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=UJetJGXy c=1 sm=1 tr=0 cx=a_idp_d
	a=P9M234EABmfYNCwpuVjnFw==:117 a=P9M234EABmfYNCwpuVjnFw==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=oexKYjalfGEA:10
	a=VwQbUJbxAAAA:8 a=pGLkceISAAAA:8 a=iox4zFpeAAAA:8 a=7-415B0cAAAA:8
	a=drOt6m5kAAAA:8 a=VlU3oBYPLQ4wDVVSrwAA:9 a=te7xfvE6NDnlrWn0:21
	a=2RiGNtYlV72RUmA0:21 a=CjuIK1q_8ugA:10 a=AjGcO6oz07-iQ99wixmX:22
	a=WzC6qhA0u3u7Ye7llzcV:22 a=biEYGPWJfzWAr4FL6Ov7:22
	a=RMMjzBEyIzXRtoq5n5K6:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 08:45:59AM +0300, Amir Goldstein wrote:
> Commit 23d0127096cb ("fs/sync.c: make sync_file_range(2) use WB_SYNC_NONE
> writeback") claims that sync_file_range(2) syscall was "created for
> userspace to be able to issue background writeout and so waiting for
> in-flight IO is undesirable there" and changes the writeback (back) to
> WB_SYNC_NONE.
> 
> This claim is only partially true. It is true for users that use the flag
> SYNC_FILE_RANGE_WRITE by itself, as does PostgreSQL, the user that was
> the reason for changing to WB_SYNC_NONE writeback.
> 
> However, that claim is not true for users that use that flag combination
> SYNC_FILE_RANGE_{WAIT_BEFORE|WRITE|_WAIT_AFTER}.
> Those users explicitly requested to wait for in-flight IO as well as to
> writeback of dirty pages.
> 
> Re-brand that flag combination as SYNC_FILE_RANGE_WRITE_AND_WAIT
> and use the helper filemap_write_and_wait_range(), that uses WB_SYNC_ALL
> writeback, to perform the full range sync request.
> 
> Link: http://lkml.kernel.org/r/20190409114922.30095-1-amir73il@gmail.com
> Fixes: 23d0127096cb ("fs/sync.c: make sync_file_range(2) use WB_SYNC_NONE")
> Signed-off-by: Amir Goldstein <amir73il@gmail.com>
> Acked-by: Jan Kara <jack@suse.com>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> ---
> 
> Andrew,
> 
> V2 of this patch is on your mmtotm queue.
> However, I had already sent out V3 with a braino fix and Dave Chinner
> just added more review comments which I had addressed in this version.
> 
> Thanks,
> Amir.
> 
> Changes since v3:
> - Remove unneeded change to VALID_FLAGS (Dave)
> - Call file_fdatawait_range() before writeback (Dave)
> 
> Changes since v2:
> - Return after filemap_write_and_wait_range()
> 
> Changes since v1:
> - Remove non-guaranties of the API from commit message
> - Added ACK by Jan
> 
>  fs/sync.c               | 20 +++++++++++++++-----
>  include/uapi/linux/fs.h |  3 +++
>  2 files changed, 18 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/sync.c b/fs/sync.c
> index b54e0541ad89..1836328f1ae8 100644
> --- a/fs/sync.c
> +++ b/fs/sync.c
> @@ -235,9 +235,9 @@ SYSCALL_DEFINE1(fdatasync, unsigned int, fd)
>  }
>  
>  /*
> - * sys_sync_file_range() permits finely controlled syncing over a segment of
> + * ksys_sync_file_range() permits finely controlled syncing over a segment of
>   * a file in the range offset .. (offset+nbytes-1) inclusive.  If nbytes is
> - * zero then sys_sync_file_range() will operate from offset out to EOF.
> + * zero then ksys_sync_file_range() will operate from offset out to EOF.
>   *
>   * The flag bits are:
>   *
> @@ -254,7 +254,7 @@ SYSCALL_DEFINE1(fdatasync, unsigned int, fd)
>   * Useful combinations of the flag bits are:
>   *
>   * SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE: ensures that all pages
> - * in the range which were dirty on entry to sys_sync_file_range() are placed
> + * in the range which were dirty on entry to ksys_sync_file_range() are placed
>   * under writeout.  This is a start-write-for-data-integrity operation.
>   *
>   * SYNC_FILE_RANGE_WRITE: start writeout of all dirty pages in the range which
> @@ -266,10 +266,13 @@ SYSCALL_DEFINE1(fdatasync, unsigned int, fd)
>   * earlier SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE operation to wait
>   * for that operation to complete and to return the result.
>   *
> - * SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE|SYNC_FILE_RANGE_WAIT_AFTER:
> + * SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE|SYNC_FILE_RANGE_WAIT_AFTER
> + * (a.k.a. SYNC_FILE_RANGE_WRITE_AND_WAIT):
>   * a traditional sync() operation.  This is a write-for-data-integrity operation
>   * which will ensure that all pages in the range which were dirty on entry to
> - * sys_sync_file_range() are committed to disk.
> + * ksys_sync_file_range() are written to disk.  It should be noted that disk
> + * caches are not flushed by this call, so there are no guarantees here that the
> + * data will be available on disk after a crash.
>   *
>   *
>   * SYNC_FILE_RANGE_WAIT_BEFORE and SYNC_FILE_RANGE_WAIT_AFTER will detect any
> @@ -344,6 +347,13 @@ int ksys_sync_file_range(int fd, loff_t offset, loff_t nbytes,
>  			goto out_put;
>  	}
>  
> +	if ((flags & SYNC_FILE_RANGE_WRITE_AND_WAIT) ==
> +		     SYNC_FILE_RANGE_WRITE_AND_WAIT) {
> +		/* Unlike SYNC_FILE_RANGE_WRITE alone, uses WB_SYNC_ALL */
> +		ret = filemap_write_and_wait_range(mapping, offset, endbyte);
> +		goto out_put;
> +	}

Clunky, now that I look at it in context.

+	int	sync_mode = WB_SYNC_NONE;
+
+	if ((flags & SYNC_FILE_RANGE_WRITE_AND_WAIT) ==
+		     SYNC_FILE_RANGE_WRITE_AND_WAIT)
+		sync_mode = WB_SYNC_ALL;

.....

	if (flags & SYNC_FILE_RANGE_WRITE) {
		ret = __filemap_fdatawrite_range(mapping, offset, endbyte,
-						 WB_SYNC_NONE);
+						 sync_mode);

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

