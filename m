From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 1/3] resource: Add @flags to region_intersects()
Date: Tue, 1 Dec 2015 18:13:22 +0100
Message-ID: <20151201171322.GD4341@pd.tnic>
References: <1448404418-28800-1-git-send-email-toshi.kani@hpe.com>
 <1448404418-28800-2-git-send-email-toshi.kani@hpe.com>
 <20151201135000.GB4341@pd.tnic>
 <CAPcyv4g2n9yTWye2aVvKMP0X7mrm_NLKmGd5WBO2SesTj77gbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAPcyv4g2n9yTWye2aVvKMP0X7mrm_NLKmGd5WBO2SesTj77gbg@mail.gmail.com>
Sender: linux-acpi-owner@vger.kernel.org
To: Dan Williams <dan.j.williams@intel.com>
Cc: Toshi Kani <toshi.kani@hpe.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Tony Luck <tony.luck@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux ACPI <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-Id: linux-mm.kvack.org

On Tue, Dec 01, 2015 at 08:54:23AM -0800, Dan Williams wrote:
> On Tue, Dec 1, 2015 at 5:50 AM, Borislav Petkov <bp@alien8.de> wrote:
> > On Tue, Nov 24, 2015 at 03:33:36PM -0700, Toshi Kani wrote:
> >> region_intersects() checks if a specified region partially overlaps
> >> or fully eclipses a resource identified by @name.  It currently sets
> >> resource flags statically, which prevents the caller from specifying
> >> a non-RAM region, such as persistent memory.  Add @flags so that
> >> any region can be specified to the function.
> >>
> >> A helper function, region_intersects_ram(), is added so that the
> >> callers that check a RAM region do not have to specify its iomem
> >> resource name and flags.  This interface is exported for modules,
> >> such as the EINJ driver.
> >>
> >> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> >> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> >> Cc: Andrew Morton <akpm@linux-foundation.org>
> >> Cc: Vishal Verma <vishal.l.verma@intel.com>
> >> ---
> >>  include/linux/mm.h |    4 +++-
> >>  kernel/memremap.c  |    5 ++---
> >>  kernel/resource.c  |   23 ++++++++++++++++-------
> >>  3 files changed, 21 insertions(+), 11 deletions(-)
> >>
> >> diff --git a/include/linux/mm.h b/include/linux/mm.h
> >> index 00bad77..c776af3 100644
> >> --- a/include/linux/mm.h
> >> +++ b/include/linux/mm.h
> >> @@ -362,7 +362,9 @@ enum {
> >>       REGION_MIXED,
> >>  };
> >>
> >> -int region_intersects(resource_size_t offset, size_t size, const char *type);
> >> +int region_intersects(resource_size_t offset, size_t size, const char *type,
> >> +                     unsigned long flags);
> >> +int region_intersects_ram(resource_size_t offset, size_t size);
> >>
> >>  /* Support for virtually mapped pages */
> >>  struct page *vmalloc_to_page(const void *addr);
> >> diff --git a/kernel/memremap.c b/kernel/memremap.c
> >> index 7658d32..98f52f1 100644
> >> --- a/kernel/memremap.c
> >> +++ b/kernel/memremap.c
> >> @@ -57,7 +57,7 @@ static void *try_ram_remap(resource_size_t offset, size_t size)
> >>   */
> >>  void *memremap(resource_size_t offset, size_t size, unsigned long flags)
> >>  {
> >> -     int is_ram = region_intersects(offset, size, "System RAM");
> >
> > Ok, question: why do those resource things types gets identified with
> > a string?! We have here "System RAM" and next patch adds "Persistent
> > Memory".
> >
> > And "persistent memory" or "System RaM" won't work and this is just
> > silly.
> >
> > Couldn't struct resource have gained some typedef flags instead which we
> > can much easily test? Using the strings looks really yucky.
> >
> 
> At least in the case of region_intersects() I was just following
> existing strcmp() convention from walk_system_ram_range.

Oh sure, I didn't mean you. I was simply questioning that whole
identify-resource-by-its-name approach. And that came with:

67cf13ceed89 ("x86: optimize resource lookups for ioremap")

I just think it is silly and that we should be identifying resource
things in a more robust way.

Btw, the ->name thing in struct resource has been there since a *long*
time, added by:

commit 40f6b7cc623f95d2a08b9adae7a6793055af4768
Author: linus1 <torvalds@linuxfoundation.org>
Date:   Wed Jun 30 11:00:00 1999 -0600

    Import 2.3.11pre1

I'm not sure what it was used for, perhaps for human-readable output in
/proc/iomem.

Let me CC Linus, he would know, most likely. akpm is already on CC.

> We could define 'const char *system_ram = "System RAM"' somewhere and
> then do pointer comparisons to cut down on the thrash of adding new
> flags to 'struct resource'?

See above. I think flags or type_flags or so should be cleaner/better...

I could be missing some aspect though, according to which, the name is
the proper way to ident those but I can't think of one...

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
