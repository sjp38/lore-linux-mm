From: John Stoffel <stoffel@casc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15135.37871.373389.465893@gargle.gargle.HOWL>
Date: Thu, 7 Jun 2001 10:47:11 -0400
Subject: Re: [PATCH] Reap dead swap cache earlier v2
In-Reply-To: <Pine.LNX.4.21.0106061705250.3769-100000@freak.distro.conectiva>
References: <Pine.LNX.4.21.0106061705250.3769-100000@freak.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo> As suggested by Linus, I've cleaned the reapswap code to be
Marcelo> contained inside an inline function. (yes, the if statement
Marcelo> is really ugly)

Shouldn't the "swap_count(page) == 1" check be earlier in the if
statement, so we can fall through more quickly if there is no work to
be done?  A small optimization, but putting the common cases first
will help.

Marcelo> +static inline int clean_dead_swap_page (struct page* page)
Marcelo> +{
Marcelo> +	int ret = 0;
Marcelo> +	if (!TryLockPage (page)) { 
Marcelo> +		if (PageSwapCache(page) && PageDirty(page) &&
Marcelo> +				(page_count(page) - !!page->buffers) == 1 &&
Marcelo> +				swap_count(page) == 1) { 
Marcelo> +			ClearPageDirty(page);
Marcelo> +			ClearPageReferenced(page);
Marcelo> +			page->age = 0;
Marcelo> +			ret = 1;
Marcelo> +		}


Thanks,
John
   John Stoffel - Senior Unix Systems Administrator - Lucent Technologies
	 stoffel@lucent.com - http://www.lucent.com - 978-952-7548
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
