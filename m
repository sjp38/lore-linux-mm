Date: Tue, 20 Nov 2001 22:29:20 -0800 (PST)
Message-Id: <20011120.222920.51691672.davem@redhat.com>
Subject: Re: 2.4.14 + Bug in swap_out.
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <m1vgg41x3x.fsf@frodo.biederman.org>
References: <m1vgg41x3x.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ebiederm@xmission.com
Cc: torvalds@transmeta.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

   And looking in fork.c mmput under with right circumstances becomes.
   kmem_cache_free(mm_cachep, (mm)))
   
   So it appears that there is nothing that keeps the mm_struct that
   swap_mm points to as being valid. 

I do not agree with your analysis.

If we hold the mmlist lock and we find the mm on the swap mm list, by
definition it must have a non-zero user count already.  (put an assert
there if you don't believe me :-)

Only when the user count drops to zero will mmput() free up the mm.
It simultaneously grabs the mmlist lock when it drops the user count
to zero, this is how it synchronizes with the rest of the world.
Perhaps you aren't noticing that it is using "atomic_dec_and_lock()"
or you don't understand how that primitive works?

We increment the mm user count before dropping the mmlist lock in the
swapper, so even if the user does a mmput() we still hold a reference.
ie. mmput won't put the user count to zero.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
