Date: Fri, 15 Apr 2005 09:53:55 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: question on page-migration code
Message-ID: <20050415125355.GA19190@logos.cnet>
References: <425AC268.4090704@engr.sgi.com> <20050412.084143.41655902.taka@valinux.co.jp> <1113324392.8343.53.camel@localhost> <20050413.194800.74725991.taka@valinux.co.jp> <20050414155734.GE14975@logos.cnet> <20050415064138.4AD8E70471@sv1.valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050415064138.4AD8E70471@sv1.valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, haveblue@us.ibm.com, raybry@engr.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Toshihiro,

On Fri, Apr 15, 2005 at 03:41:38PM +0900, IWAMOTO Toshihiro wrote:
> At Thu, 14 Apr 2005 12:57:34 -0300,
> Marcelo Tosatti wrote:
> > 
> > On Wed, Apr 13, 2005 at 07:48:00PM +0900, Hirokazu Takahashi wrote:
> 
> > 2) PG_dirty bit set on anonymous pages which have been migrated.
> > 
> > > ray> I guess it seems to me that if a page has pte dirty set, but doesn't have
> > > ray> PG_dirty set, then that state should be carried over to the newpage after
> > > ray> a migration, rather than sweeping the pte dirty bit into the PG_dirty bit.
> > 
> > The dirty bit is set by swap allocation and freeing code. 
> > 
> > > The implementation might be as follows:
> > >    - to make try_to_unmap_one() record dirty bit in anywhere
> > >      instead of calling set_page_dirty().
> > >    - to make touch_unmapped_address() call get_user_pages() with
> > >      the record of the dirty bit.
> > 
> > Quoting Ray:
> > "Checking /proc/vmstat/pgpgout appears to indicate that the pages I am
> > migrating are being swapped out when I see the migration slow down,
> > although something is fishy with pgpgout."
> > 
> > Anonymous pages seem to the problem Ray is seeing, except (1) which 
> > vanishes with ext2/ext3 as he reports.
> 
> I think Ray is using the word "swap" to mean "page out" and anonymous
> pages are irrelevant here, judging from his another mail (quoted below).

Ah, OK.

> At Tue, 12 Apr 2005 00:43:42 -0500,
> Ray Bryant wrote:
> : BTW, the program that I am testing creates a relatively large mapped file,
> : and, as you guessed, this file is backed by XFS.  Programs that just use
> : large amounts of anonymous storage are not effected by this problem, I
> : would imagine.
> 
> > One point is that if free memory is below the safe watermarks, the
> > system will vmscan, allocating swap & writing out, which is expected.
> 
> If there are enough RAM, mmaped dirty pages shouldn't be written back.
> However, memory migration triggers writebacks.
> 
> > > However, we have to remember that there must exit some race conditions.
> > > For example, it may fail to restore the dirty bit since the process
> > > address spaces might be deleted during the memory migration.
> > > This may occur as the process isn't suspended during the migration.
> > 
> > The PG_dirty bit is set, by the migration code, for anonymous pages only.
> 
> If a file page is mmaped and its PTE is dirty, the page gets PG_dirty
> bit when it is unmapped. 

Right. 

> > That said, I see no need to reset PG_dirty in case it was not set before
> > migration, as you propose.
> 
> I think PG_dirty should be reset, as the side effect is probably
> unacceptable for Ray's application.  It would be a bit more
> complicated than just changing page and PTE bits, but I think it's
> doable.

Yes, makes sense.

Question: Who is causing the writeouts here? 

Is there memory pressure or is it pdflush? 

Its not the migration code? (that would be a problem I think).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
