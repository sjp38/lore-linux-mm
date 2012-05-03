Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 0E7AB6B00EB
	for <linux-mm@kvack.org>; Thu,  3 May 2012 05:46:02 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2847265pbb.14
        for <linux-mm@kvack.org>; Thu, 03 May 2012 02:46:01 -0700 (PDT)
Date: Thu, 3 May 2012 02:44:38 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 0/3] vmevent: Implement 'low memory' attribute
Message-ID: <20120503094438.GA17744@lizard>
References: <20120501132409.GA22894@lizard>
 <CAOJsxLGxKdDnw6RU=1C3VVrwZJ53k_r6gOddYkjxQxjc1-kRXg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAOJsxLGxKdDnw6RU=1C3VVrwZJ53k_r6gOddYkjxQxjc1-kRXg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Thu, May 03, 2012 at 11:10:12AM +0300, Pekka Enberg wrote:
> On Tue, May 1, 2012 at 4:24 PM, Anton Vorontsov
> <anton.vorontsov@linaro.org> wrote:
> > Accounting only free pages is very inaccurate for low memory handling,
> > so we have to be smarter here.
> 
> Can you elaborate on what kind of problems there are with tracking free pages?

Well, there's no problem with tracking itself, the word 'inaccurate'
was probably misleading. Tracking just free pages is inaccurate for
our "low memory" notification needs, but NR_FREE_PAGES tracking
itself is fine.

The thing is that NR_FREE_PAGES accounts only completely unused
(wasted) pages. Most of the time we have very low NR_FREE_PAGES,
and lots of page cache and block buffers (i.e. NR_FILE_PAGES).

The file pages are easily reclaimable (except shmem/tmpfs and
locked pages), so file pages may be considered as "somewhat
free" pages.

The cache might contain very stale data (or not), so we have to
maneuver between the two strategies: sacrifice caches, or start
freeing memory (which prevents caches draining).

The strategy is described in the third patch in the series.
It might be not ideal, but the logic itself is not part of
the ABI (this is very similar "not ABI" rules as we have for
OOM scoring logic), and is subject for changes.

Thanks,

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
