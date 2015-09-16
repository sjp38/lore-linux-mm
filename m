Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id 460686B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:47:20 -0400 (EDT)
Received: by ykft14 with SMTP id t14so75091894ykf.0
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:47:20 -0700 (PDT)
Received: from mail-yk0-x236.google.com (mail-yk0-x236.google.com. [2607:f8b0:4002:c07::236])
        by mx.google.com with ESMTPS id q3si12399746ywc.190.2015.09.16.10.47.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Sep 2015 10:47:19 -0700 (PDT)
Received: by ykdt18 with SMTP id t18so206572959ykd.3
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:47:19 -0700 (PDT)
Date: Wed, 16 Sep 2015 13:47:15 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] fs: global sync to not clear error status of
 individual inodes
Message-ID: <20150916174715.GF3243@mtj.duckdns.org>
References: <20150915094638.GA13399@xzibit.linux.bs1.fc.nec.co.jp>
 <20150915095412.GD13399@xzibit.linux.bs1.fc.nec.co.jp>
 <20150915152006.GD2905@mtj.duckdns.org>
 <20150916005916.GB6059@xzibit.linux.bs1.fc.nec.co.jp>
 <20150916083908.GA12244@xzibit.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150916083908.GA12244@xzibit.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Junichi Nomura <j-nomura@ce.jp.nec.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "tony.luck@intel.com" <tony.luck@intel.com>, "david@fromorbit.com" <david@fromorbit.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Wed, Sep 16, 2015 at 08:39:09AM +0000, Junichi Nomura wrote:
> filemap_fdatawait() is a function to wait for on-going writeback
> to complete but also consume and clear error status of the mapping
> set during writeback.
> The latter functionality is critical for applications to detect
> writeback error with system calls like fsync(2)/fdatasync(2).
> 
> However filemap_fdatawait() is also used by sync(2) or FIFREEZE
> ioctl, which don't check error status of individual mappings.
> 
> As a result, fsync() may not be able to detect writeback error
> if events happen in the following order:
> 
>    Application                    System admin
>    ----------------------------------------------------------
>    write data on page cache
>                                   Run sync command
>                                   writeback completes with error
>                                   filemap_fdatawait() clears error
>    fsync returns success
>    (but the data is not on disk)
> 
> This patch adds filemap_fdatawait_keep_errors() for call sites where
> writeback error is not handled so that they don't clear error status.
> 
> Signed-off-by: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
> Acked-by: Andi Kleen <ak@linux.intel.com>

Reviewed-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
