Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 23D386B005A
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 15:24:56 -0400 (EDT)
Received: by iec9 with SMTP id 9so2140565iec.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 12:24:55 -0700 (PDT)
Date: Wed, 5 Sep 2012 12:24:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: fix potential anon_vma locking issue in mprotect()
In-Reply-To: <20120905101142.GP3334@redhat.com>
Message-ID: <alpine.LSU.2.00.1209051204020.4626@eggly.anvils>
References: <1346801989-18274-1-git-send-email-walken@google.com> <20120904164636.158d8012.akpm@linux-foundation.org> <CANN689HVhMogAWjLAEJOkaKL0DL-ECD_eZngrCQqaUrQ6pubeA@mail.gmail.com> <20120905101142.GP3334@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org

On Wed, 5 Sep 2012, Andrea Arcangeli wrote:
> On Tue, Sep 04, 2012 at 05:02:49PM -0700, Michel Lespinasse wrote:
> > On Tue, Sep 4, 2012 at 4:46 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > > On Tue,  4 Sep 2012 16:39:49 -0700
> > > Michel Lespinasse <walken@google.com> wrote:
> > >
> > >> This change fixes an anon_vma locking issue in the following situation:
> > >> - vma has no anon_vma
> > >> - next has an anon_vma
> > >> - vma is being shrunk / next is being expanded, due to an mprotect call
> > >>
> > >> We need to take next's anon_vma lock to avoid races with rmap users
> > >> (such as page migration) while next is being expanded.

Mmm, good catch by Michel.

I got interested in the history of this, and checked back: we had this
locking right before 2.6.34, when it got lost somewhere in the succession
of changes for the anon_vma chains.

In 2.6.33, we were also locking next anon_vma for the remove_next case,
and I got worried that Michel's patch might be incomplete: but no,
nowadays the unlinking of the anon_vma is handled further down, getting
that lock quite separately in unlink_anon_vmas() (from "anon_vma_merge").

Acked-by: Hugh Dickins <hughd@google.com>

> > >
> > > hm, OK.  How serious was that bug?  I'm suspecting "only needed in
> > > 3.7".
> 
> Agreed.
> 
> > That was my starting position as well. I'd expect the biggest issue
> > would be page migration races, and we do have assertions for that
> > case, and we've not been hitting them (that I know of). So, this
> > should not be a high frequency issue AFAICT.
> 
> I exclude it's reproducible with real load too, the window is far too
> small.
> 
> A malicious load might reproduce it, but the worst case would be to
> trigger the BUG_ON assertion in migration_entry_to_page like you
> mentioned above or to "gracefully" hang in migration_entry_wait, or to
> trigger one of the BUG_ONs in split_huge_page with no risk of memory
> corruption or anything.

Yes, that malicious Mr Dave Jones is the most likely to trigger it.

I'll defer to you and Andrew and Michel as to whether the fix should
go to stable: you think not, and I agree it's a very narrow window,
whose only danger is triggering one of those BUG_ONs.

But certainly I'm glad that Michel and Andrew have separated it out
as a fix which can be applied independent of his series.

Hugh

> 
> The only two places in the VM that depends on full accuracy in finding
> all ptes from the rmap walk are remove_migration_ptes and
> split_huge_page and they both are (and must remain) robust enough not
> to generate memory corruption or any other adverse side effects if the
> rmap walk actually wasn't 100% accurate because of some race condition
> like in this case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
