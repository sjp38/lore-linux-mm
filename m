Date: Thu, 29 May 2003 04:23:33 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.70-mm2
Message-Id: <20030529042333.3dd62255.akpm@digeo.com>
In-Reply-To: <20030529012914.2c315dad.akpm@digeo.com>
References: <20030529012914.2c315dad.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@digeo.com> wrote:
>
> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.70/2.5.70-mm2/
> 
> 
> . A couple more locking mistakes in ext3 have been fixed.
> 

But not all of them.  The below is needed on SMP.

diff -puN fs/jbd/transaction.c~x fs/jbd/transaction.c
--- 25-whoops/fs/jbd/transaction.c~x	2003-05-29 04:21:51.000000000 -0700
+++ 25-whoops-akpm/fs/jbd/transaction.c	2003-05-29 04:22:09.000000000 -0700
@@ -2077,12 +2077,13 @@ void __journal_refile_buffer(struct jour
  */
 void journal_refile_buffer(journal_t *journal, struct journal_head *jh)
 {
-	struct buffer_head *bh;
+	struct buffer_head *bh = jh2bh(jh);
 
+	jbd_lock_bh_state(bh);
 	spin_lock(&journal->j_list_lock);
-	bh = jh2bh(jh);
 
 	__journal_refile_buffer(jh);
+	jbd_unlock_bh_state(bh);
 	journal_remove_journal_head(bh);
 
 	spin_unlock(&journal->j_list_lock);

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
