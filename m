Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id DE5656B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 07:00:56 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so3090140pbc.14
        for <linux-mm@kvack.org>; Fri, 23 Mar 2012 04:00:56 -0700 (PDT)
Date: Fri, 23 Mar 2012 04:00:23 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC]swap: don't do discard if no discard option added
In-Reply-To: <CANejiEUyPSNQ7q85ZDz-B3iHikHLgZLBNOF-p4evkxjGo5+M0g@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1203230338110.31703@eggly.anvils>
References: <4F68795E.9030304@kernel.org> <alpine.LSU.2.00.1203202019140.1842@eggly.anvils> <CANejiEUyPSNQ7q85ZDz-B3iHikHLgZLBNOF-p4evkxjGo5+M0g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Holger Kiehl <Holger.Kiehl@dwd.de>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jason Mattax <jmattax@storytotell.org>, linux-mm@kvack.org

On Wed, 21 Mar 2012, Shaohua Li wrote:
> Holger uses raid for swap. We currently didn't do discard request
> merge as low SCSI driver doesn't allow. So for the raid0 case, we
> will split big discard request to chunk size, which is 512k. This will
> increase discard request number. This can be fixed later.

Are you sure that's a significant factor?  I can certainly imagine it
magnifying the issue, but only Vertex2 has been reported as a problem.

> But on
> the other hand, if user doesn't explictly enable discard, why enable
> it? Like fs, we didn't do runtime discard and only run trim occasionally

Historic really: swap discard went in early, when it sounded like just
the right thing for swap, and we imagined that vendors would implement
it sensibly if they implemented it at all.

There appeared to be no need for such a flag at that time.  But once
different firmwares appeared, and also block developers switched discard
over from using a barrier to waiting for completion, the use of discard
when allocating fresh clusters became often much slower: so we added the
flag for that case.

The use of discard at swapon time still appeared to be a worthwhile win,
not needing any flag: swapon is indeed occasional.  But now the Vertex2
has shown just how unbearable that can be.

> since discard is slow.

On the Vertex2 - or do you know of others which pose this problem?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
