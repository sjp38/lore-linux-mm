Date: Mon, 30 Aug 2004 15:37:30 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on
 swap partition
Message-Id: <20040830153730.18e431c2.akpm@osdl.org>
In-Reply-To: <20040830203339.GA2955@logos.cnet>
References: <20040828151349.00f742f4.akpm@osdl.org>
	<20040828222816.GZ5492@holomorphy.com>
	<20040829033031.01c5f78c.akpm@osdl.org>
	<20040829141526.GC10955@suse.de>
	<20040829141718.GD10955@suse.de>
	<20040829131824.1b39f2e8.akpm@osdl.org>
	<20040829203011.GA11878@suse.de>
	<20040829135917.3e8ffed8.akpm@osdl.org>
	<20040830152025.GA2901@logos.cnet>
	<41336B6F.6050806@pandora.be>
	<20040830203339.GA2955@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: karl.vogel@pandora.be, axboe@suse.de, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
>
>  static int may_write_to_queue(struct backing_dev_info *bdi)
>  {
> +	int nr_writeback = read_page_state(nr_writeback);
> +
> +	if (nr_writeback > (totalram_pages * 25 / 100)) { 
> +		blk_congestion_wait(WRITE, HZ/5);
> +		return 0;
> +	}

That's probably a good way of special-casing this special-place problem.

For a final patch I'd be inclined to take into account /proc/sys/vm/dirty_ratio
and to avoid running the expensive read_page_state() once per writepage.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
