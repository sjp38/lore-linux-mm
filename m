Message-ID: <003001c27041$e9e24320$1003a8c0@cybage.com>
Reply-To: "Dharmender Rai" <dharmenderr@cybage.com>
From: "Dharmender Rai" <dharmenderr@cybage.com>
References: <20021010084944.45912.qmail@web12508.mail.yahoo.com> <3DA540F3.75957C69@scs.ch>
Subject: Re: Meaning of the dirty bit
Date: Thu, 10 Oct 2002 15:16:31 +0530
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Maletinsky <maletinsky@scs.ch>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi ,

Read the //// commented part in the following code mentioned by you:

* Do a quick page-table lookup for a single page.
  */
 static struct page * follow_page(unsigned long address, int write)
{
 	pgd_t *pgd;
 	pmd_t *pmd;
                     pte_t *ptep, pte;

 pgd = pgd_offset(current->mm, address);
/// initialized page directory entry or the page directory entry is invalid
 if (pgd_none(*pgd) || pgd_bad(*pgd))
 	goto out;
 pmd = pmd_offset(pgd, address);
/// initialized page middle directory entry or the page middle directory
entry is invalid
 if (pmd_none(*pmd) || pmd_bad(*pmd))
 	goto out;

 ptep = pte_offset(pmd, address);
 if (!ptep)
 	goto out;

 pte = *ptep;
//// if the page table entry is valid
 if (pte_present(pte)) {
 	if (!write ||
//// page is write-able and dirty
      (pte_write(pte) && pte_dirty(pte)))
  	return pte_page(pte);
 }

out:
 return 0;
}

The logic here is very simple. This function is used to detect  one page.
Now a writeable and dirty page is the most suitable one as this page's
content has to be written out on the disk. Suppose you go for the read only
page then you will be interrupting the processes that might be reading from
that page.


Regards,
Dharmender Rai
================================
Dharmender Rai,
Cybage Software Pvt. Ltd,
Kalyani Nagar,
Pune -411006

Phone : 6686359
Extn    :    261
----- Original Message -----
From: "Martin Maletinsky" <maletinsky@scs.ch>
To: <dharmenderr@cybage.com>
Cc: <kernelnewbies@nl.linux.org>; <linux-mm@kvack.org>
Sent: Thursday, October 10, 2002 2:27 PM
Subject: Re: Meaning of the dirty bit


> Hello,
>
> Thanks for your reply. What is the reason to check the dirty bit in
follow_page(), which (presumably) should just parse the page tables, verify
write access (if the write
> argument is set) and return the page descriptor describing the page the
address is in (from what I understood, there is no I/O involved).
> Is there any reason to deny write access when the dirty flag is not set?
>
> Thanks again,
> regards
> Martin
>
> Dharmender Rai wrote:
>
> > Hi,
> > The purpose is to achieve need-based disk I/O.
> > Dirty-flag-set means you have to write the contents of
> > that page to the disk before paging out or
> > invalidating that page. If the dirty flag is not set
> > then there is no need for the I/O part.
> >
> > Regards
> > Dharmender Rai
> >
> >  --- Martin Maletinsky <maletinsky@scs.ch> wrote: >
> > Hi,
> > >
> > > While studying the follow_page() function (the
> > > version of the function that is in place since
> > > 2.4.4, i.e. with the write argument), I noticed,
> > > that for an address that
> > > should be written to (i.e. write != 0), the function
> > > checks not only the writeable flag (with
> > > pte_write()), but also the dirty flag (with
> > > pte_dirty()) of the page
> > > containing this address.
> > > From what I thought to understand from general
> > > paging theory, the dirty flag of a page is set, when
> > > its content in physical memory differs from its
> > > backing on the permanent
> > > storage system (file or swap space). Based on this
> > > understanding I do not understand why it is
> > > necessary to check the dirty flag, in order to
> > > ensure that a page is writable
> > > - what am I missing here?
> > >
> > > Thanks in advance for any answers
> > > with best regards
> > > Martin Maletinsky
> > >
> > > P.S. Pls. put me on cc: in your reply, since I am
> > > not on the mailing list.
> > >
> > > --
> > > Supercomputing System AG          email:
> > > maletinsky@scs.ch
> > > Martin Maletinsky                 phone: +41 (0)1
> > > 445 16 05
> > > Technoparkstrasse 1               fax:   +41 (0)1
> > > 445 16 10
> > > CH-8005 Zurich
> > >
> > >
> > > --
> > > Kernelnewbies: Help each other learn about the Linux
> > > kernel.
> > > Archive:
> > > http://mail.nl.linux.org/kernelnewbies/
> > > FAQ:           http://kernelnewbies.org/faq/
> > >
> >
> > __________________________________________________
> > Do You Yahoo!?
> > Everything you'll ever need on one web page
> > from News and Sport to Email and Music Charts
> > http://uk.my.yahoo.com
>
> --
> Supercomputing System AG          email: maletinsky@scs.ch
> Martin Maletinsky                 phone: +41 (0)1 445 16 05
> Technoparkstrasse 1               fax:   +41 (0)1 445 16 10
> CH-8005 Zurich
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
