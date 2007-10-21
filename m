Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l9L7THAm342514
	for <linux-mm@kvack.org>; Sun, 21 Oct 2007 07:29:17 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9L7TH2T3113034
	for <linux-mm@kvack.org>; Sun, 21 Oct 2007 08:29:17 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9L7T51P010498
	for <linux-mm@kvack.org>; Sun, 21 Oct 2007 08:29:06 +0100
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH] rd: Use a private inode for backing storage
Date: Sun, 21 Oct 2007 09:28:58 +0200
References: <200710151028.34407.borntraeger@de.ibm.com> <200710211524.52595.nickpiggin@yahoo.com.au> <m1d4v9c690.fsf@ebiederm.dsl.xmission.com>
In-Reply-To: <m1d4v9c690.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710210928.58265.borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Am Sonntag, 21. Oktober 2007 schrieb Eric W. Biederman:
> Nick.  Reread the patch.  The only thing your arguments have
> established for me is that this patch is not obviously correct.  Which
> makes it ineligible for a back port.  Frankly I suspect the whole
> issue is to subtle and rare to make any backport make any sense.  My
> apologies Christian.

About being rare, when I force the VM to be more aggressive reclaiming buffer
by using the following patch:
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -3225,7 +3225,7 @@ void __init buffer_init(void)
 	 * Limit the bh occupancy to 10% of ZONE_NORMAL
 	 */
 	nrpages = (nr_free_buffer_pages() * 10) / 100;
-	max_buffer_heads = nrpages * (PAGE_SIZE / sizeof(struct buffer_head));
+	max_buffer_heads = 0;
 	hotcpu_notifier(buffer_cpu_notify, 0);
 }
 
I can actually cause data corruption within some seconds. So I think the
problem is real enough to be worth fixing.

I still dont fully understand what issues you have with my patch.
- it obviously fixes the problem
- I am not aware of any regression it introduces
- its small

One concern you had, was the fact that buffer heads are out of sync with 
struct pages. Testing your first patch revealed that this is actually needed
by reiserfs - and maybe others.
I can also see, that my patch looks a bit like a bandaid that cobbles the rd
pieces together.
Is there anything else, that makes my patch unmergeable in your opinion?


Christian






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
