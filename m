Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0E79B6B02D9
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 21:08:39 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g23so22449122wme.4
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 18:08:39 -0800 (PST)
Received: from celine.tisys.org (celine.tisys.org. [85.25.117.166])
        by mx.google.com with ESMTPS id xs6si20587244wjc.244.2016.12.19.18.08.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 18:08:37 -0800 (PST)
Date: Tue, 20 Dec 2016 03:08:29 +0100
From: Nils Holland <nholland@tisys.org>
Subject: Re: OOM: Better, but still there on
Message-ID: <20161220020829.GA5449@boerne.fritz.box>
References: <20161216073941.GA26976@dhcp22.suse.cz>
 <20161216155808.12809-1-mhocko@kernel.org>
 <20161216184655.GA5664@boerne.fritz.box>
 <20161217000203.GC23392@dhcp22.suse.cz>
 <20161217125950.GA3321@boerne.fritz.box>
 <862a1ada-17f1-9cff-c89b-46c47432e89f@I-love.SAKURA.ne.jp>
 <20161217210646.GA11358@boerne.fritz.box>
 <20161219134534.GC5164@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161219134534.GC5164@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Mon, Dec 19, 2016 at 02:45:34PM +0100, Michal Hocko wrote:

> Unfortunatelly shrink_active_list doesn't have any tracepoint so we do
> not know whether we managed to rotate those pages. If they are referenced
> quickly enough we might just keep refaulting them... Could you try to apply
> the followin diff on top what you have currently. It should add some more
> tracepoint data which might tell us more. We can reduce the amount of
> tracing data by enabling only mm_vmscan_lru_isolate,
> mm_vmscan_lru_shrink_inactive and mm_vmscan_lru_shrink_active.

So, the results are in! I applied your patch and rebuild the kernel,
then I rebooted the machine, set up tracing so that only the three
events you mentioned were being traced, and captured the output over
the network.

Things went a bit different this time: The trace events started to
appear after a while and a whole lot of them were generated, but
suddenly they stopped. A short while later, we get

[ 1661.485568] btrfs-transacti: page alloction stalls for 611058ms, order:0, mode:0x2420048(GFP_NOFS|__GFP_HARDWALL|__GFP_MOVABLE)

along with a backtrace and memory information, and then there was
silence. When I walked up to the machine, it had completely died; it
wouldn't turn on its screen on key press any more, blindly trying to
reboot via SysRequest had no effect, but the caps lock LED also wasn't
blinking, like it normally does when a kernel panic occurs. Good
question what state it was in. The OOM reaper didn't really seem to
kick in and kill processes this time, it seems.

The complete capture is up at:

http://ftp.tisys.org/pub/misc/teela_2016-12-20.log.xz

Greetings
Nils

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
