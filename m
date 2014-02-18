Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3CEA56B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 07:04:36 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id hm4so3399558wib.2
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 04:04:35 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k1si14298951wjz.126.2014.02.18.04.04.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 04:04:34 -0800 (PST)
Date: Tue, 18 Feb 2014 13:04:30 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH V6 ] mm readahead: Fix readahead fail for memoryless cpu
 and limit readahead pages
Message-ID: <20140218120430.GC29660@quack.suse.cz>
References: <1392708338-19685-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
 <20140218094920.GB29660@quack.suse.cz>
 <53034C66.90707@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53034C66.90707@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, rientjes@google.com, Linus <torvalds@linux-foundation.org>, nacc@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 18-02-14 17:34:54, Raghavendra K T wrote:
> On 02/18/2014 03:19 PM, Jan Kara wrote:
> >On Tue 18-02-14 12:55:38, Raghavendra K T wrote:
> >>Currently max_sane_readahead() returns zero on the cpu having no local memory node
> >>which leads to readahead failure. Fix the readahead failure by returning
> >>minimum of (requested pages, 512). Users running application on a memory-less cpu
> >>which needs readahead such as streaming application see considerable boost in the
> >>performance.
> >>
> >>Result:
> >>fadvise experiment with FADV_WILLNEED on a PPC machine having memoryless CPU
> >>with 1GB testfile ( 12 iterations) yielded around 46.66% improvement.
> >>
> >>fadvise experiment with FADV_WILLNEED on a x240 machine with 1GB testfile
> >>32GB* 4G RAM  numa machine ( 12 iterations) showed no impact on the normal
> >>NUMA cases w/ patch.
> >   Can you try one more thing please? Compare startup time of some big
> >executable (Firefox or LibreOffice come to my mind) for the patched and
> >normal kernel on a machine which wasn't hit by this NUMA issue. And don't
> >forget to do "echo 3 >/proc/sys/vm/drop_caches" before each test to flush
> >the caches. If this doesn't show significant differences, I'm OK with the
> >patch.
> >
> 
> Thanks Honza, I checked with firefox (starting to particular point)..
> I do not see any difference. Both the case took around 14sec.
  Good. You can add my:
Acked-by: Jan Kara <jack@suse.cz>

>  ( some time it is even faster.. may be because we do not do free
> page calculation?. )
  Hardly, that calculation is just a tiny amount of CPU time in the
startup of the application. If there is really a significant difference, it
might be because we don't preload stuff which isn't used in the end.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
