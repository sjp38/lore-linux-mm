Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 47947828EA
	for <linux-mm@kvack.org>; Sat, 30 Jul 2016 13:31:20 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id l2so169591261qkf.2
        for <linux-mm@kvack.org>; Sat, 30 Jul 2016 10:31:20 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id u16si15829174qki.63.2016.07.30.10.31.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jul 2016 10:31:19 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id q8so9133641qke.3
        for <linux-mm@kvack.org>; Sat, 30 Jul 2016 10:31:19 -0700 (PDT)
Date: Sat, 30 Jul 2016 13:31:15 -0400
From: George Amvrosiadis <gamvrosi@gmail.com>
Subject: Re: [PATCH 0/3] new feature: monitoring page cache events
Message-ID: <20160730173115.GA23083@thinkpad>
References: <cover.1469489884.git.gamvrosi@gmail.com>
 <579A72F5.10808@intel.com>
 <20160729034745.GA10234@leftwich>
 <579B774E.10309@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <579B774E.10309@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 29, 2016 at 08:33:34AM -0700, Dave Hansen wrote:
> What's to stop you from using tracing to gather and transport data out
> of the kernel and then aggregate and present it to apps in an "elegant"
> way of your choosing?
> 
> I don't think it's really even worth having an in-depth discussion of
> how to modify duet.  I can't imagine that this would get merged as-is,
> or even anything resembling the current design.  If you want to see
> duet-like functionality in the kernel, I think it needs to be integrated
> better and enhance or take advantage of existing mechanisms.
> 
> You've identified a real problem and a real solution, and it is in an
> area where Linux is weak (monitoring the page cache).  If you are really
> interested in seeing a solution that folks can use, I think you need to
> find some way to leverage existing kernel functionality (ftrace,
> fanotify, netlink, etc...), or come up with a much more compelling story
> about why you can't use them.

I took a few measurements of the ftrace overhead, and if limited to the page
cache functions we're interested in, it's very reasonable. Duet does depend
on exporting some data with each event, however, and tracepoints seem to be
the most efficient way to do this. There are two issues, however:

(a) There are no tracepoints for page dirtying and flushing. Those would have
to be added at the same place as the Duet hooks I submitted (unwrapping the
page-flags.h macros) to catch those cases where pages are locked and the dirty
bit is set manually.

(b) The page cache tracepoints are currently not exported symbols. If I can
export those four tracepoints for page addition, removal, dirtying, and
flushing, then the rest of the work (exporting the information to userspace)
can be carried out within a module. In the future, once we reach a point of
maturity where we are confident about the stability of the exporting interface
and performance, we could engage in another conversation about potentially
mainlining some of that code.

Dave, I can produce a patch that adds the extra two tracepoints and exports
all four tracepoint symbols. This would be a short patch that would just
extend existing tracing functionality. What do you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
