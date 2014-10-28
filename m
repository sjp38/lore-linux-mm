Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3631A900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 13:43:52 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so1224171pab.22
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 10:43:51 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qd9si1837590pdb.221.2014.10.28.10.43.50
        for <linux-mm@kvack.org>;
        Tue, 28 Oct 2014 10:43:51 -0700 (PDT)
Message-ID: <544FD5D4.4090404@intel.com>
Date: Tue, 28 Oct 2014 10:43:48 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v9 05/12] x86, mpx: on-demand kernel allocation of bounds
 tables
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-6-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241257300.5308@nanos>
In-Reply-To: <alpine.DEB.2.11.1410241257300.5308@nanos>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Qiaowei Ren <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On 10/24/2014 05:08 AM, Thomas Gleixner wrote:
> On Sun, 12 Oct 2014, Qiaowei Ren wrote:
>> +	/*
>> +	 * Go poke the address of the new bounds table in to the
>> +	 * bounds directory entry out in userspace memory.  Note:
>> +	 * we may race with another CPU instantiating the same table.
>> +	 * In that case the cmpxchg will see an unexpected
>> +	 * 'actual_old_val'.
>> +	 */
>> +	ret = user_atomic_cmpxchg_inatomic(&actual_old_val, bd_entry,
>> +					   expected_old_val, bt_addr);
> 
> This is fully preemptible non-atomic context, right?
> 
> So this wants a proper comment, why using
> user_atomic_cmpxchg_inatomic() is the right thing to do here.

Hey Thomas,

How's this for a new comment?  Does this cover the points you think need
clarified?

====

The kernel has allocated a bounds table and needs to point the
(userspace-allocated) directory to it.  The directory entry is the
*only* place we track that this table was allocated, so we essentially
use it instead of an kernel data structure for synchronization.  A
copy_to_user()-style function would not give us the atomicity that we need.

If two threads race to instantiate a table, the cmpxchg ensures we know
which one lost the race and that the loser frees the table that they
just allocated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
