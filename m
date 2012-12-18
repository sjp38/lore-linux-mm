Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id A74DB6B0070
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 02:30:46 -0500 (EST)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 18 Dec 2012 07:30:06 -0000
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBI7UZ5w2425192
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 07:30:35 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost.localdomain [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBI7Ugf8013729
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 00:30:43 -0700
Date: Tue, 18 Dec 2012 08:30:41 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] mm: Fix XFS oops due to dirty pages without buffers on
 s390
Message-ID: <20121218083041.06f80d17@mschwide>
In-Reply-To: <alpine.LNX.2.00.1212171459090.26086@eggly.anvils>
References: <1350918406-11369-1-git-send-email-jack@suse.cz>
	<20121022123852.a4bd5f2a.akpm@linux-foundation.org>
	<20121023102153.GD3064@quack.suse.cz>
	<20121023145636.0a9b9a3e.akpm@linux-foundation.org>
	<20121025200141.GF3262@quack.suse.cz>
	<20121214094505.0163bda6@mschwide>
	<alpine.LNX.2.00.1212171459090.26086@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, linux-s390@vger.kernel.org

On Mon, 17 Dec 2012 15:31:47 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> On Fri, 14 Dec 2012, Martin Schwidefsky wrote:
> > 
> > The patch got delayed a bit,
> 
> Thanks a lot for finding the time to do this:
> I never expected it to get priority.
> 
> > the main issue is to get conclusive performance
> > measurements about the effects of the patch. I am pretty sure that the patch
> > works and will not cause any major degradation so it is time to ask for your
> > opinion. Here we go:
> 
> If if works reliably and efficiently for you on s390, then I'm strongly in
> favour of it; and I cannot imagine who would not be - it removes several
> hunks of surprising and poorly understood code from the generic mm end.
> 
> I'm slightly disappointed to be reminded of page_test_and_clear_young(),
> and find it still there; but it's been an order of magnitude less
> troubling than the _dirty, so not worth more effort I guess.

To remove the dependency on the referenced-bit in the storage key would
require to set the invalid bit on the pte until the first access has been
done. Then the referenced bit would have to be set and a valid pte can
be established. That would be costly, because we would get a lot more
program checks on the invalid, old ptes. So the page_test_and_clear_young
needs to stay. The situation for the referenced bits is much more relaxed
though, we can afford to loose the one of the other referenced bit
without ill effect. I would not worry about page_test_and_clear_young
too much.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
