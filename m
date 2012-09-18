Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 30A9B6B0069
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 18:09:36 -0400 (EDT)
Date: Tue, 18 Sep 2012 15:09:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 1/5] mm: introduce a common interface for balloon
 pages mobility
Message-Id: <20120918150933.cab895b8.akpm@linux-foundation.org>
In-Reply-To: <20120918162420.GB1645@optiplex.redhat.com>
References: <cover.1347897793.git.aquini@redhat.com>
	<89c9f4096bbad072e155445fcdf1805d47ddf48e.1347897793.git.aquini@redhat.com>
	<20120917151543.fd523040.akpm@linux-foundation.org>
	<20120918162420.GB1645@optiplex.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, 18 Sep 2012 13:24:21 -0300
Rafael Aquini <aquini@redhat.com> wrote:

> On Mon, Sep 17, 2012 at 03:15:43PM -0700, Andrew Morton wrote:
> > > +/* return code to identify when a ballooned page has been migrated */
> > > +#define BALLOON_MIGRATION_RETURN	0xba1100
> > 
> > I didn't really spend enough time to work out why this was done this
> > way, but I know a hack when I see one!
> >
> Yes, I'm afraid it's a hack, but, unfortunately, it's a necessary one (IMHO).
> 
> This 'distinct' return code is used to flag a sucessful balloon page migration
> at the following unmap_and_move() snippet (patch 2).
> If by any reason we fail to identify a sucessfull balloon page migration, we
> will cause a page leak, as the old 'page' won't be properly released.
> .....
>         rc = __unmap_and_move(page, newpage, force, offlining, mode);
> +
> +        if (unlikely(rc == BALLOON_MIGRATION_RETURN)) {
> +                /*
> +                 * A ballooned page has been migrated already.
> +                 * Now, it's the time to remove the old page from the isolated
> +                 * pageset list and handle it back to Buddy, wrap-up counters
> +                 * and return.
> +                 */
> ......
> 
> By reaching that point in code, we cannot rely on testing page->mapping flags
> anymore for both 'page' and 'newpage' because:
> a) migration has already finished and 'page'->mapping is wiped out;
> b) balloon might have started to deflate, and 'newpage' might be released
>    already;
> 
> If the return code approach is unnaceptable, we might defer the 'page'->mapping
> wipe-out step to that point in code for the balloon page case.
> That, however, tends to be a little bit heavier, IMHO, as it will require us to
> acquire the page lock once more to proceed the mapping wipe out, thus
> potentially introducing overhead by lock contention (specially when several
> parallel compaction threads are scanning pages for isolation)

I think the return code approach _is_ acceptable, but the
implementation could be improved.

As it stands, a naive caller could be expecting either 0 (success) or a
negative errno.  A large positive return value could trigger havoc.  We
can defend against such programming mistakes with code commentary, but
a better approach would be to enumerate the return values.  Along the
lines of

/*
 * Return values from addresss_space_operations.migratepage().  Returns a
 * negative errno on failure.
 */
#define MIGRATEPAGE_SUCCESS		0
#define MIGRATEPAGE_BALLOON_THINGY	1	/* nice comment goes here */

and convert all callers to explicitly check for MIGRATEPAGE_SUCCESS,
not literal zero.  We should be particularly careful to look for
codesites which are unprepared for positive return values, such as

	ret = migratepage();
	if (ret < 0)
		return ret;
	...
	return ret;		/* success!! */



If we wanted to be really vigilant about this, we could do

#define MIGRATEPAGE_SUCCESS		1
#define MIGRATEPAGE_BALLOON_THINGY	2

so any naive code which tests for literal zero will nicely explode early
in testing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
