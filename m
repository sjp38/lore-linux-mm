Message-ID: <394C1115.37F8D7CB@norran.net>
Date: Sun, 18 Jun 2000 02:00:21 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: PATCH: Improvements in shrink_mmap and kswapd
References: <ytt3dmcyli7.fsf@serpe.mitica> <394C0A09.CD2CBF62@norran.net> <20000617174201.A28257@puffin.external.hp.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Philipp Rumpf <prumpf@puffin.external.hp.com>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, Alan Cox <alan@lxorguk.ukuu.org.uk>, lkml <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, linux-fsdevel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Philipp Rumpf wrote:
> 
> On Sun, Jun 18, 2000 at 01:30:17AM +0200, Roger Larsson wrote:
> > > diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/include/asm-i386/bitops.h working/include/asm-i386/bitops.h
> > > --- base/include/asm-i386/bitops.h      Sat Jun 17 23:37:03 2000
> > > +++ working/include/asm-i386/bitops.h   Sat Jun 17 23:52:49 2000
> > > @@ -29,6 +29,7 @@
> > >  extern void change_bit(int nr, volatile void * addr);
> > >  extern int test_and_set_bit(int nr, volatile void * addr);
> > >  extern int test_and_clear_bit(int nr, volatile void * addr);
> > > +extern int test_and_test_and_clear_bit(int nr, volatile void * addr);
> > >  extern int test_and_change_bit(int nr, volatile void * addr);
> > >  extern int __constant_test_bit(int nr, const volatile void * addr);
> > >  extern int __test_bit(int nr, volatile void * addr);
> > > @@ -87,6 +88,13 @@
> > >                 :"=r" (oldbit),"=m" (ADDR)
> > >                 :"Ir" (nr));
> > >         return oldbit;
> > > +}
> > > +
> > > +extern __inline__ int test_and_test_and_clear_bit(int nr, volatile void *addr)
> > > +{
> > > +       if(!(((unsigned long)addr) & (1<<nr)))
> > > +               return 0;
> > > +       return test_and_clear_bit(nr,addr);
> > >  }
> >
> >
> > This does not look correct. It basically tests if the ADDRESS has bit
> > #nr set...
> >
> > Shouldn't it be
> > +       if(!(((unsigned long)*addr) & (1<<nr)))
> 
> if(!((*(unsigned long *)addr) & (1<<nr))
> 
> is closer to what you want. it still breaks for nr > BITS_PER_LONG.


Final attempt:

return test_bit(nr,addr) && test_and_clear_bit(nr,addr);

It even matches the name :-)
But it have to be moved some lines down.
(Exercise for the reader)

/RogerL
--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
