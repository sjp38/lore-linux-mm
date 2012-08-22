Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 9CBB26B0044
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 16:14:58 -0400 (EDT)
Date: Wed, 22 Aug 2012 22:14:55 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: mmu_notifier: fix inconsistent memory between
 secondary MMU and host
Message-ID: <20120822201455.GB8107@redhat.com>
References: <503358FF.3030009@linux.vnet.ibm.com>
 <20120821150618.GJ27696@redhat.com>
 <5034763D.60508@linux.vnet.ibm.com>
 <20120822162955.GT29978@redhat.com>
 <20120822121535.8be38858.akpm@linux-foundation.org>
 <20120822195043.GA8107@redhat.com>
 <20120822125805.9c62aa79.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120822125805.9c62aa79.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, LKML <linux-kernel@vger.kernel.org>, KVM <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Aug 22, 2012 at 12:58:05PM -0700, Andrew Morton wrote:
> If you can suggest some text I'll type it in right now.

Ok ;), I tried below:

This is safe to start by updating the secondary MMUs, because the
relevant primary MMU pte invalidate must have already happened with a
ptep_clear_flush before set_pte_at_notify has been invoked. Updating
the secondary MMUs first is required when we change both the
protection of the mapping from read-only to read-write and the pfn
(like during copy on write page faults). Otherwise the old page would
remain mapped readonly in the secondary MMUs after the new page is
already writable by some CPU through the primary MMU."

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
