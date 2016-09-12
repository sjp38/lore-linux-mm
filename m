Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2ACA6B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 11:01:54 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g202so365413652pfb.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 08:01:54 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id u86si6415779pfg.287.2016.09.12.08.01.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Sep 2016 08:01:52 -0700 (PDT)
Subject: Re: [PATCH v2] mm, proc: Fix region lost in /proc/self/smaps
References: <1473649964-20191-1-git-send-email-guangrong.xiao@linux.intel.com>
 <20160912125447.GM14524@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57D6C332.4000409@intel.com>
Date: Mon, 12 Sep 2016 08:01:06 -0700
MIME-Version: 1.0
In-Reply-To: <20160912125447.GM14524@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Xiao Guangrong <guangrong.xiao@linux.intel.com>
Cc: pbonzini@redhat.com, akpm@linux-foundation.org, dan.j.williams@intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com, Oleg Nesterov <oleg@redhat.com>

On 09/12/2016 05:54 AM, Michal Hocko wrote:
>> > In order to fix this bug, we make 'file->version' indicate the end address
>> > of current VMA
> Doesn't this open doors to another weird cases. Say B would be partially
> unmapped (tail of the VMA would get unmapped and reused for a new VMA.

In the end, this interface isn't about VMAs.  It's about addresses, and
we need to make sure that the _addresses_ coming out of it are sane.  In
the case that a VMA was partially unmapped, it doesn't make sense to
show the "new" VMA because we already had some output covering the
address of the "new" VMA from the old one.

> I am not sure we provide any guarantee when there are more read
> syscalls. Hmm, even with a single read() we can get inconsistent results
> from different threads without any user space synchronization.

Yeah, very true.  But, I think we _can_ at least provide the following
guarantees (among others):
1. addresses don't go backwards
2. If there is something at a given vaddr during the entirety of the
   life of the smaps walk, we will produce some output for it.

> So in other words isn't this fixing a bug by introducing a slightly
> different one while we are not really guaranteeing anything strong here?

Well, the (original) bug here _is_ pretty crummy.  It's not printing a
VMA, and that VMA was never touched.  It's just collateral damage from
the previous guy who got destroyed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
