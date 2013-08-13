Return-Path: <owner-linux-mm@kvack.org>
Date: Wed, 14 Aug 2013 08:54:25 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 0/3] Pin page control subsystem
Message-ID: <20130813235425.GA2271@bbox>
References: <1376377502-28207-1-git-send-email-minchan@kernel.org>
 <1376387202.31048.2.camel@AMDC1943>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1376387202.31048.2.camel@AMDC1943>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, guz.fnst@cn.fujitsu.com, Benjamin LaHaise <bcrl@kvack.org>, Dave Hansen <dave.hansen@intel.com>, lliubbo@gmail.com, aquini@redhat.com, Rik van Riel <riel@redhat.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>

Hello Krzysztof,

On Tue, Aug 13, 2013 at 11:46:42AM +0200, Krzysztof Kozlowski wrote:
> Hi Minchan,
> 
> On wto, 2013-08-13 at 16:04 +0900, Minchan Kim wrote:
> > patch 2 introduce pinpage control
> > subsystem. So, subsystems want to control pinpage should implement own
> > pinpage_xxx functions because each subsystem would have other character
> > so what kinds of data structure for managing pinpage information depends
> > on them. Otherwise, they can use general functions defined in pinpage
> > subsystem. patch 3 hacks migration.c so that migration is
> > aware of pinpage now and migrate them with pinpage subsystem.
> 
> I wonder why don't we use page->mapping and a_ops? Is there any
> disadvantage of such mapping/a_ops?

Most concern of the approach is how to handle nested pin case.
For example, driver A and driver B pin same file-backed page
conincidently by get_user_pages.
For the migration, we needs following operations.

1. [buffer]'s migrate_page for the file-backed page
2. [driver A]'s migrate_page 
3. [driver B]'s migrate_page

But the page's mapping is only one. How can we handle it?

If we give up pinpage subsystem unifying userspace pages(ex, GUP)
and kernel space pages(ex, zswap, zram and zcache), we can go
address_space's migatepages but we might lost abstraction so that
all of users should implement own pinpage manager. It's not hard,
I guess but it's more error-prone and not maintainable for the future.

> 
> Best regards,
> Krzysztof
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
