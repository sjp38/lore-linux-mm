Date: Mon, 27 Jan 2003 20:11:42 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] page coloring for 2.5.59 kernel, version 1
Message-ID: <20030128041142.GG780@holomorphy.com>
References: <3.0.6.32.20030127224726.00806c20@boo.net> <20030128035736.GF780@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030128035736.GF780@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jason Papadopoulos <jasonp@boo.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 27, 2003 at 07:57:36PM -0800, William Lee Irwin III wrote:
> set_num_colors() needs to go downstairs under arch/ Some of the
> current->pid checks look a bit odd esp. for GFP_ATOMIC and/or
> in_interrupt() cases. I'm not sure why this is a config option; it
> should be mandatory. I also wonder about the interaction of this with
> the per-cpu lists. This may really want to be something like a matrix
> with (cpu, color) indices to find the right list; trouble is, there's a
> high potential for many pages to be trapped there. mapnr's (page -
> zone->zone_mem_map etc.) are being used for pfn's; this may raise
> issues if zones' required alignments aren't num_colors*PAGE_SIZE or
> larger. proc_misc.c can be used instead of page_color_init(). ->free_list
> can be removed. get_rand() needs locking, per-zone state. Useful stuff.

Hmm, actually the mapnr's as physical pfn's are broken with
MAP_NR_DENSE(), though existing boxen probably luck out. The RNG uses
an integer multiply which may be slow on various cpus, and I wouldn't
mind either a stronger or better documented RNG algorithm. ->color_init
is basically a bitflag, and ->target_color has a very limited range.
sizeof(task_t) needs to be small, could you fold that stuff into
->flags or ->thread_info?

-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
