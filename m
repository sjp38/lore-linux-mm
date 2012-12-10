Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 8BAE26B0071
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 15:08:43 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so2366708pad.14
        for <linux-mm@kvack.org>; Mon, 10 Dec 2012 12:08:42 -0800 (PST)
Date: Mon, 10 Dec 2012 12:05:12 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [RFC v2] Add mempressure cgroup
Message-ID: <20121210200512.GA499@lizard>
References: <20121210095838.GA21065@lizard>
 <201212101323.09806.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <201212101323.09806.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Mon, Dec 10, 2012 at 01:23:09PM +0100, Bartlomiej Zolnierkiewicz wrote:
> On Monday 10 December 2012 10:58:38 Anton Vorontsov wrote:
> 
> > +static void consume_memory(void)
> > +{
> > +	unsigned int i = 0;
> > +	unsigned int j = 0;
> > +
> > +	puts("consuming memory...");
> > +
> > +	while (1) {
> > +		pthread_mutex_lock(&locks[i]);
> > +		if (!chunks[i]) {
> > +			chunks[i] = malloc(CHUNK_SIZE);
> > +			pabort(!chunks[i], 0, "chunks alloc failed");
> > +			memset(chunks[i], 0, CHUNK_SIZE);
> > +			j++;
> > +		}
> > +		pthread_mutex_unlock(&locks[i]);
> > +
> > +		if (j >= num_chunks / 10) {
> > +			add_reclaimable(num_chunks / 10);
> 
> Shouldn't it use j instead of num_chunks / 10 here?

Um.. They should be equal. Or am I missing the point?

> > +			printf("added %d reclaimable chunks\n", j);
> > +			j = 0;

Here, we reset it.

> > +		}
> > +
> > +		i = (i + 1) % num_chunks;
> > +	}
> > +}

Thanks!
Anton.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
