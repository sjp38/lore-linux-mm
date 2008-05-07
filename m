Date: Wed, 7 May 2008 11:14:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] more ZERO_PAGE handling ( was 2.6.24 regression:
 deadlock on coredump of big process)
Message-Id: <20080507111404.871b8990.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080430061125.GF27652@wotan.suse.de>
References: <4815E932.1040903@cybernetics.com>
	<20080429100048.3e78b1ba.kamezawa.hiroyu@jp.fujitsu.com>
	<48172C72.1000501@cybernetics.com>
	<20080430132516.28f1ee0c.kamezawa.hiroyu@jp.fujitsu.com>
	<4817FDA5.1040702@kolumbus.fi>
	<20080430141738.e6b80d4b.kamezawa.hiroyu@jp.fujitsu.com>
	<20080430051932.GD27652@wotan.suse.de>
	<20080430143542.2dcf745a.kamezawa.hiroyu@jp.fujitsu.com>
	<20080430061125.GF27652@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Mika =?UTF-8?B?UGVudHRpbMOk?= <mika.penttila@kolumbus.fi>, Tony Battersby <tonyb@cybernetics.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 30 Apr 2008 08:11:25 +0200
Nick Piggin <npiggin@suse.de> wrote:
  
> >  	pte = *ptep;
> > -	if (!pte_present(pte))
> > +	if (!pte_present(pte)) {
> > +		if (!(flags & FOLL_WRITE) && pte_none(pte)) {
> > +			pte_unmap_unlock(ptep, ptl);
> > +			goto null_or_zeropage;
> > +		}
> >  		goto unlock;
> > +	}
> 
> Just a small nitpick: I guess you don't need this FOLL_WRITE test because
> null_or_zeropage will test FOLL_ANON which implies !FOLL_WRITE. It should give
> slightly smaller code.
> 
> Otherwise, looks good to me:
> 
Hmm, but 

do_execve()
  -> copy_strings()
       -> get_arg_page()
            -> get_user_pages()

can do write-page-fault in ANON (and it's a valid ops.)

So, I think it's safe not to remove FOLL_WRITE check here.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
