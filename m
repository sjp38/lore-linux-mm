From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] rd: Use a private inode for backing storage
References: <200710151028.34407.borntraeger@de.ibm.com>
	<200710211524.52595.nickpiggin@yahoo.com.au>
	<m1d4v9c690.fsf@ebiederm.dsl.xmission.com>
	<200710210928.58265.borntraeger@de.ibm.com>
Date: Sun, 21 Oct 2007 02:23:54 -0600
In-Reply-To: <200710210928.58265.borntraeger@de.ibm.com> (Christian
	Borntraeger's message of "Sun, 21 Oct 2007 09:28:58 +0200")
Message-ID: <m1zlycc1ut.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Christian Borntraeger <borntraeger@de.ibm.com> writes:

> Am Sonntag, 21. Oktober 2007 schrieb Eric W. Biederman:
>> Nick.  Reread the patch.  The only thing your arguments have
>> established for me is that this patch is not obviously correct.  Which
>> makes it ineligible for a back port.  Frankly I suspect the whole
>> issue is to subtle and rare to make any backport make any sense.  My
>> apologies Christian.
>
> About being rare, when I force the VM to be more aggressive reclaiming buffer
> by using the following patch:
> --- linux-2.6.orig/fs/buffer.c
> +++ linux-2.6/fs/buffer.c
> @@ -3225,7 +3225,7 @@ void __init buffer_init(void)
>  	 * Limit the bh occupancy to 10% of ZONE_NORMAL
>  	 */
>  	nrpages = (nr_free_buffer_pages() * 10) / 100;
> -	max_buffer_heads = nrpages * (PAGE_SIZE / sizeof(struct buffer_head));
> +	max_buffer_heads = 0;
>  	hotcpu_notifier(buffer_cpu_notify, 0);
>  }
>  
> I can actually cause data corruption within some seconds. So I think the
> problem is real enough to be worth fixing.

Let me put it another way.  Looking at /proc/slabinfo I can get 
37 buffer_heads per page.  I can allocate 10% of memory in
buffer_heads before we start to reclaim them.  So it requires just
over 3.7 buffer_heads on very page of low memory to even trigger
this case.  That is a large 1k filesystem or a weird sized partition,
that we have written to directly.

That makes this condition very rare in practice without your patch.

Especially since even after we reach the above condition we have
to have enough vm pressure to find a page with clean buffer heads
that is dirty in the ramdisk.

While it can be done deterministically usually it is pretty hard
to trigger and pretty easy to work around by simply using partition
sizes that are a multiple of 4k and 4k block sized filesystems.

> I still dont fully understand what issues you have with my patch.
> - it obviously fixes the problem
> - I am not aware of any regression it introduces
> - its small

My primary issue with your patch is that it continues the saga the
trying to use buffer cache to store the data which is a serious
review problem, and clearly not what we want to do long term.

> One concern you had, was the fact that buffer heads are out of sync with 
> struct pages. Testing your first patch revealed that this is actually needed
> by reiserfs - and maybe others.
> I can also see, that my patch looks a bit like a bandaid that cobbles the rd
> pieces together.

> Is there anything else, that makes my patch unmergeable in your
> opinion?

For linus's tree the consensus is that to fix rd.c that we
need to have a backing store that is stored somewhere besides
in the page cache/buffer cache for /dev/ram0.   Doing that prevents
all of the weird issues.

Now we have the question of which patch gets us there.  I contend
I have implemented it with my last little patch that this thread
is a reply to.  Nick hasn't seen that just yet.

So if we have a small patch that can implement the proper long
term fix I contend we are in better shape.

As for backports we can worry about that after we get something
sane merged upstream.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
