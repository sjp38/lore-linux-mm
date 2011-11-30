Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 3350A6B0055
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 19:24:34 -0500 (EST)
Date: Wed, 30 Nov 2011 08:24:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 8/9] readahead: basic support for backwards prefetching
Message-ID: <20111130002425.GA8734@localhost>
References: <20111129130900.628549879@intel.com>
 <20111129131456.925952168@intel.com>
 <20111129153552.GP5635@quack.suse.cz>
 <4ED50A63.1010805@draigBrady.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4ED50A63.1010805@draigBrady.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?Q?P=C3=A1draig?= Brady <P@draigBrady.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, "Li, Shaohua" <shaohua.li@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 30, 2011 at 12:37:55AM +0800, PA!draig Brady wrote:
> On 11/29/2011 03:35 PM, Jan Kara wrote:
> >   Someone already mentioned this earlier and I don't think I've seen a
> > response: Do you have a realistic usecase for this? I don't think I've ever
> > seen an application reading file backwards...
> 
> tac, tail -n$large, ...

Indeed!
             tac-4425  [000] 73358.419777: readahead: readahead-random(dev=0:16, ino=1548445, req=750+1, ra=750+1-0, async=0) = 1
             tac-4425  [004] 73358.442030: readahead: readahead-backwards(dev=0:16, ino=1548445, req=748+2, ra=746+5-0, async=0) = 4
             tac-4425  [004] 73358.443312: readahead: readahead-backwards(dev=0:16, ino=1548445, req=744+2, ra=726+25-0, async=0) = 20

            tail-4369  [000] 72633.696307: readahead: readahead-random(dev=0:16, ino=1548450, req=750+1, ra=750+1-0, async=0) = 1
            tail-4369  [004] 72634.042106: readahead: readahead-backwards(dev=0:16, ino=1548450, req=748+2, ra=746+5-0, async=0) = 4
            tail-4369  [004] 72634.043231: readahead: readahead-backwards(dev=0:16, ino=1548450, req=744+2, ra=726+25-0, async=0) = 20
            tail-4369  [004] 72634.176216: readahead: readahead-backwards(dev=0:16, ino=1548450, req=724+2, ra=626+125-0, async=0) = 100

However I see the readahead requests always be snapped to EOF.

So it's obvious the "snap to EOF" logic need some limiting based on
max readahead size.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
