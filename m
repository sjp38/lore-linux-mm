Date: Thu, 3 Apr 2003 12:56:34 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH 2.5.66-mm2] Fix page_convert_anon locking issues
Message-Id: <20030403125634.5afa54fb.akpm@digeo.com>
In-Reply-To: <20030403120611.6691399e.akpm@digeo.com>
References: <8910000.1049303582@baldur.austin.ibm.com>
	<20030402132939.647c74a6.akpm@digeo.com>
	<80300000.1049320593@baldur.austin.ibm.com>
	<20030402150903.21765844.akpm@digeo.com>
	<102170000.1049325787@baldur.austin.ibm.com>
	<20030402153845.0770ef54.akpm@digeo.com>
	<110950000.1049326945@baldur.austin.ibm.com>
	<20030402155220.651a1005.akpm@digeo.com>
	<116640000.1049327888@baldur.austin.ibm.com>
	<92070000.1049381395@[10.1.1.5]>
	<20030403120611.6691399e.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: dmccr@us.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@digeo.com> wrote:
>
> page_referenced() has the same problem, so refill_inactive_zone() will need
> to lock pages too.

Complete bollocks.  As long as the pte chains are consistent while
refill_inactive_zone holds pte_chain_lock (they darn well should be),
concurrent page_referenced() and page_convert_anon() is fine.

It could be that page_referenced() returns an inappropriate answer, but it's
so rare we don't care.

Which is good.  We really don't want to lock pages in refill_inactive_zone()
to keep the extremely rare page_convert_anon() away.  refill_inactive_zone()
is more a bath-temperature path than a hotpath, but still...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
