Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 951BF6B0071
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 08:23:18 -0500 (EST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MEV00JOJBUSNPY0@mailout4.samsung.com> for
 linux-mm@kvack.org; Tue, 11 Dec 2012 22:23:16 +0900 (KST)
Received: from amdc1032.localnet ([106.116.147.136])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MEV007TEBUREP30@mmp1.samsung.com> for linux-mm@kvack.org;
 Tue, 11 Dec 2012 22:23:16 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [RFC v2] Add mempressure cgroup
Date: Tue, 11 Dec 2012 14:22:38 +0100
References: <20121210095838.GA21065@lizard>
 <201212101323.09806.b.zolnierkie@samsung.com> <20121210200512.GA499@lizard>
In-reply-to: <20121210200512.GA499@lizard>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7bit
Message-id: <201212111422.38970.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Monday 10 December 2012 21:05:12 Anton Vorontsov wrote:
> On Mon, Dec 10, 2012 at 01:23:09PM +0100, Bartlomiej Zolnierkiewicz wrote:
> > On Monday 10 December 2012 10:58:38 Anton Vorontsov wrote:
> > 
> > > +static void consume_memory(void)
> > > +{
> > > +	unsigned int i = 0;
> > > +	unsigned int j = 0;
> > > +
> > > +	puts("consuming memory...");
> > > +
> > > +	while (1) {
> > > +		pthread_mutex_lock(&locks[i]);
> > > +		if (!chunks[i]) {
> > > +			chunks[i] = malloc(CHUNK_SIZE);
> > > +			pabort(!chunks[i], 0, "chunks alloc failed");
> > > +			memset(chunks[i], 0, CHUNK_SIZE);
> > > +			j++;
> > > +		}
> > > +		pthread_mutex_unlock(&locks[i]);
> > > +
> > > +		if (j >= num_chunks / 10) {
> > > +			add_reclaimable(num_chunks / 10);
> > 
> > Shouldn't it use j instead of num_chunks / 10 here?
> 
> Um.. They should be equal. Or am I missing the point?

Oh, ok.  You're right.

j > num_chunks / 10 condition should never happen and may be removed.

> > > +			printf("added %d reclaimable chunks\n", j);
> > > +			j = 0;
> 
> Here, we reset it.
> 
> > > +		}
> > > +
> > > +		i = (i + 1) % num_chunks;
> > > +	}
> > > +}
> 
> Thanks!
> Anton.

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
