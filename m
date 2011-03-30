Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4AD988D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 21:05:37 -0400 (EDT)
Date: Tue, 29 Mar 2011 18:06:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH]mmap: add alignment for some variables
Message-Id: <20110329180611.a71fe829.akpm@linux-foundation.org>
In-Reply-To: <1301446882.3981.33.camel@sli10-conroe>
References: <1301277536.3981.27.camel@sli10-conroe>
	<m2oc4v18x8.fsf@firstfloor.org>
	<1301360054.3981.31.camel@sli10-conroe>
	<20110329152434.d662706f.akpm@linux-foundation.org>
	<1301446882.3981.33.camel@sli10-conroe>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Wed, 30 Mar 2011 09:01:22 +0800 Shaohua Li <shaohua.li@intel.com> wrote:

> +/*
> + * Make sure vm_committed_as in one cacheline and not cacheline shared with
> + * other variables. It can be updated by several CPUs frequently.
> + */
> +struct percpu_counter vm_committed_as ____cacheline_internodealigned_in_smp;

The mystery deepens.  The only cross-cpu writeable fields in there are
percpu_counter.lock and its companion percpu_counter.count.  If CPUs
are contending for the lock then that itself is a problem - how does
adding some padding to the struct help anything?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
