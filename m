Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id XAA18275
	for <linux-mm@kvack.org>; Tue, 5 Jan 1999 23:59:47 -0500
Received: from mirkwood.dummy.home (root@anx1p8.phys.uu.nl [131.211.33.97])
	by max.phys.uu.nl (8.8.7/8.8.7/hjm) with ESMTP id FAA03225
	for <linux-mm@kvack.org>; Wed, 6 Jan 1999 05:59:17 +0100 (MET)
Received: from localhost (riel@localhost) by mirkwood.dummy.home (8.9.0/8.8.3) with ESMTP id FAA14106 for <linux-mm@kvack.org>; Wed, 6 Jan 1999 05:58:59 +0100
Date: Wed, 6 Jan 1999 05:58:58 +0100 (CET)
From: Rik van Riel <riel@humbolt.geo.uu.nl>
Subject: Space allocation using skiplists (fwd)
Message-ID: <Pine.LNX.4.03.9901060557270.12629-200000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY=------------33FA6A6F2354
Content-ID: <Pine.LNX.4.03.9901060557271.12629@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--------------33FA6A6F2354
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.03.9901060557272.12629@mirkwood.dummy.home>

Hi,

I just received this algorithm from one of the visitors
to the Linux-MM site (I'm surviving the /. effect fine)
and it could be interesting.

Since it's now almost 6 AM I haven't given it much though
myself yet :)

Rik -- If a Microsoft product fails, who do you sue?
+-------------------------------------------------------------------+
| Linux memory management tour guide.        riel@humbolt.geo.uu.nl |
| Scouting Vries cubscout leader.    http://humbolt.geo.uu.nl/~riel |
+-------------------------------------------------------------------+



---------- Forwarded message ----------
Date: Tue, 05 Jan 1999 23:39:15 -0500
From: N. D. Culver <ndc@alum.mit.edu>
To: H.H.vanRiel@phys.uu.nl
Subject: Space allocation using skiplists

Hi,

I'm now reading the Linux memory management pages
and see that you are working on new methods. Years
ago I wrote a multi-heap allocator implemented with
skip-lists which has some algorithms that might
prove useful. A version is attached, go ahead and
use whatever you want from it.

Regards,
Norman Culver

--------------33FA6A6F2354
Content-Type: TEXT/PLAIN; CHARSET=us-ascii; NAME="oxmalloc.c"
Content-ID: <Pine.LNX.4.03.9901060557273.12629@mirkwood.dummy.home>
Content-Description: 
Content-Disposition: INLINE; FILENAME="oxmalloc.c"

/* OXMALLOC ================ MULTI HEAP MALLOC ========================== 


 Copyright (c) 1995 Norman D. Culver dba Oxbow Software
					1323 S.E. 17th Street #662
					Ft. Lauderdale, FL 33316
					(954)463-4754 Voice
					ndc@alum.mit.edu
 
 THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

	
    This implementation of malloc has some unique features.

      1. Multiple heaps (categories) are very convenient because
         the programmer can free an entire heapnum of allocations
         instead of ensuring that each malloc is paired with a free.
         Space returned from a heap is added to the base heap, normally
         heapnum 0. Heaps do not have to be preallocated to a particular
         sized amount.
      2. It is implemented with skip lists. The overhead per allocation
         is usually 32 bytes.
      3. Nevertheless it competes favorably with BSD (buddy block) mallocs 
         for speed and total space consumed. All bookkeeping information
         is maintained separate from the allocated space; in a demand paged
         environment this method may dramatically reduce thrashing.
      4. Individual categories can be set to 'guarded' mode in which
         case guard words are stored at the front and back of each
         allocation, the guard words are tested when the space is
         freed or reallocated.
      5. The function: heapcheckC(int heapnum, void *startaddr)
         will walk the heap forward from 'startaddr' and return a bad
         address or 0.
      6. If the user calls: heapMembug(int heapnum) a heapcheck will
         be performed every time an allocation/deallocation is requested
         for the heapnum.
*/
#include "../include/beam.h"
#include "../include/extern.h"

#if 0
/* User API -- in addition to malloc,free,... */
void *mallocH(int heapnum, unsigned amount);
void *callocH(int heapnum, unsigned nelems, unsigned elemsize);
void *reallocH(int heapnum, void* buf, unsigned newsize);
void freeH(int heapnum, void* buf);
void freeheap(int heapnum);
int memrangeH(int heapnum, unsigned* minp, unsigned* maxp);
int usedrangeH(int heapnum, unsigned* minp, unsigned* maxp);
void totrangeH(unsigned* minp,unsigned* maxp);
void *heapcheckH(int heapnum, void *start);
void guardH(int heapnum);
void *memalignH(int heapnum, unsigned alignment, unsigned req);
void heapMembug(int heapnum);
void howmuchH(int heapnum, unsigned *tot, unsigned *used);
void setReallocClr(int heapnum);
#endif

#define PICKY_ABOUT_NULL_POINTERS (0)
#define BASE_HEAP (0)
#define PAGESIZE (4096)	/* can use `pagesize' function in OS */
#define ALIGNMENTM (8)
#define MAL_MAXLEVEL (12)
#define ROUNDINGM(a) ((a+(ALIGNMENTM-1))&~(ALIGNMENTM-1))
#define ALLOCSIZE (4*1024)
#define FRNTGUARD (0x544e5246UL)
#define BACKGUARD (0x48434142UL)
#define GUARDSIZE (4)
#define CURPROC me 
#define NUMTYPES 3

#define SKIPVARS NodePM update[MAL_MAXLEVEL+1];NodePM node,prev;int level

#define ABORT() end_beam()

#ifndef _GNUC_
#define VCRASH(a,b,c) \
{error_message("FATAL CRASH: memory bug, check errorlog.txt");\
log_printf(a,b,c);ABORT();}
#else
#define VCRASH(args...) \
{error_message("FATAL CRASH: memory bug, check errorlog.txt");\
log_printf(## args);ABORT();}
#endif

#ifndef _GNUC_
#define VPRINTF
#else
#define VPRINTF(args...) \
fprintf(BEAMLOG, ## args)
#endif

#define VNOTICE(msg) \
{log_printf(msg); error_message(msg);}

#define DELETENODE(TYPE) \
{for(level=0;level<=bp->TYPE##level; level++)\
{if(update[level]->fptr[level] == node)\
update[level]->fptr[level] = node->fptr[level];else break;}\
while(bp->TYPE##level>0 && bp->TYPE##header->fptr[bp->TYPE##level]==_NILLL)\
bp->TYPE##level--;free_Mnode(node);}

#define INSERT() \
{while(level >= 0){\
node->fptr[level] = update[level]->fptr[level];\
update[level]->fptr[level] = node;level--;}}

#define SETLEVEL(TYPE) \
{level = getMlevel(bp, bp->TYPE##level);\
while(bp->TYPE##level < level)update[++bp->TYPE##level]=bp->TYPE##header;}

#define FINDKEY(TYPE, KEYVAL) \
{node = bp->TYPE##header;\
for(level = bp->TYPE##level; level >= 0; level--){\
while(node->fptr[level]->key < KEYVAL)\
node = node->fptr[level];\
update[level] = node;}prev=node;node=node->fptr[0];}

#define DETACH(SN) \
{SN->bptr->fptr=SN->fptr;if(SN->fptr)SN->fptr->bptr=SN->bptr;}

#define UNLINK(SN, N) \
{if(!sp->fptr&&sp->bptr->bptr<=(AddrP)(MAL_MAXLEVEL+1))\
dsize[N]=sp->size;\
DETACH(SN);free_addr(SN);}

#define CHECKGUARDS(MSG) \
{if(bp->guarded){\
unsigned *p2;\
p2 = (void*)((char*)address+cursize-GUARDSIZE);\
if(*address != FRNTGUARD)\
VCRASH(#MSG ":%d: corrupted at 0x%x\n", bp->bincat, addr);\
if(*p2 != BACKGUARD)\
VCRASH(#MSG ":%d: corrupted by 0x%x\n", bp->bincat, addr);}}

#define HEAPCHECK \
{char *lastaddr;\
if((lastaddr = (char*)heapcheckH(heapnum, (void*)0))){\
FINDKEY(USEDH, (unsigned)(lastaddr-ALIGNMENTM))\
fprintf(BEAMLOG,"bad heap at %p c:%u size=%u\n", lastaddr, heapnum, node->value);\
print_rawdata(lastaddr-ALIGNMENTM, node->value);\
ABORT();}}

struct _catlocs {
	void *addr;
	struct _catlocs *fptr;
};

typedef struct _nodeM
{
	unsigned key;
	unsigned value;
	unsigned levels;	/* must always be after value */
	struct _nodeM *fptr[1];
} NodeM, *NodePM;

typedef struct _addr
{
	struct _addr *fptr;
	struct _addr *bptr;
	NodePM maddr;
	unsigned size;
} *AddrP;

struct _bins {
	unsigned bits;
	unsigned nbits;
	NodePM SIZEHheader;
	int SIZEHlevel;
	NodePM FREEHheader;
	int FREEHlevel; 
	NodePM USEDHheader;
	int USEDHlevel;

	int bincat;
	unsigned maxloc;
	unsigned minloc;
	unsigned totalloc;
	unsigned usedalloc;
	int realloc_clr;
	struct _catlocs *catlocs;
	struct _bins *fptr;
	int guarded;
	int addrbump;
};

struct __malloc__ {
struct _bins zbp;
NodePM freenodes[MAL_MAXLEVEL+2];
struct _addr *freeaddrlocs;
char *bookbase;
unsigned booksize;
unsigned maxloc;
unsigned minloc;
struct _bins *freebinlocs;
struct _catlocs *freecatlocs;
unsigned int cat;
int mem_bug;
unsigned tot_alloc;
struct _bins *hmap[1009];
unsigned bookreserve[3073];
};
/* =================== STATIC STORAGE ======================= */
static struct __malloc__ me;
static struct _nodeM _nilll = {0xffffffff,0,0,{0}};
static struct _nodeM *_NILLL = &_nilll;
static int chunksizes[] = {1024,3*1024,4*1024};
static unsigned __MEMCHUNK__ = 64*1024;
static long randtbl[32]	= { 0L,
	0x9a319039L, 0x32d9c024L, 0x9b663182L, 0x5da1f342L, 
	0xde3b81e0L, 0xdf0a6fb5L, 0xf103bc02L, 0x48f340fbL, 
	0x7449e56bL, 0xbeb1dbb0L, 0xab5c5918L, 0x946554fdL, 
	0x8c2e680fL, 0xeb3d799fL, 0xb11ee0b7L, 0x2d436b86L, 
	0xda672e2aL, 0x1588ca88L, 0xe369735dL, 0x904f35f7L, 
	0xd7158fd6L, 0x6fa6f051L, 0x616e6b96L, 0xac94efdcL, 
	0x36413f93L, 0xc622c298L, 0xf5a42ab8L, 0x8a88d77bL, 
	0xf5ad9d0eL, 0x8999220bL, 0x27fb47b9L
};
static	long *fptr	= &randtbl[4];
static	long *rptr	= &randtbl[1];
/* ================== START OF CODE ================ */

static char
hexbyte(unsigned int c)
{
char x = c & 0xf;

	return x + ((x>9) ? 55 : 48);
}
static void
print_rawdata(void *rawdata, long size)
{
unsigned long vaddr = 0;
unsigned char *d = rawdata;
int i,j;
char addr[9];
char hex1[24];
char hex2[24];
char side1[9];
char side2[9];

	addr[8] = 0;
	hex1[23] = 0;
	hex2[23] = 0;
	side1[8] = 0;
	side2[8] = 0;
	while(size > 0)
	{
	unsigned long qaddr = vaddr;
		memset(addr, '0', 8);
		memset(hex1, ' ', 23);
		memset(hex2, ' ', 23);
		memset(side1, ' ', 8);
		memset(side2, ' ', 8);
		i = 7;
		while(qaddr)
		{
			addr[i--] = hexbyte(qaddr);
			qaddr >>= 4;
		}
		for(i=0,j=0; i < 8; ++i)
		{
			if(--size >= 0)
			{
			unsigned int c = *d++;
				if(isprint(c))
					side1[i] = c;
				else
					side1[i] = '.';
				hex1[j++] = hexbyte(c>>4);
				hex1[j++] = hexbyte(c);
					++j;
			}
			else break;
		}
		for(i=0,j=0; i < 8; ++i)
		{
			if(--size >= 0)
			{
			unsigned int c = *d++;
				if(isprint(c))

					side2[i] = c;					
				else
					side2[i] = '.';
				hex2[j++] = hexbyte(c>>4);
				hex2[j++] = hexbyte(c);
				++j;
			}
			else break;
		}
		fprintf(BEAMLOG,"%s  %s%s%s  %s%s%s\n", addr,hex1," | ",hex2,side1,"|",side2);
		vaddr += 16;
	}
}

/*
 * Returns a really good 31-bit random number.
 */
static long
lrandom()
{
long i;
	
	*fptr += *rptr;
	i = (*fptr >> 1) & 0x7fffffffUL;
	if(++fptr > &randtbl[31])
	{
		fptr = &randtbl[1];
		++rptr;
	}
	else
	{
		if(++rptr > &randtbl[31])  
			rptr = &randtbl[1];
	}
	return i;
}

static void *
do_sbrk(unsigned amount)
{
void *address;

	address = PORT_sbrk(amount);
	if(address == (void*)-1 || address == (void*)0)
		return 0;

	CURPROC.tot_alloc += amount;
	return address;
}
static int
get_bookspace(unsigned desired)
{
unsigned more = (desired > __MEMCHUNK__) ? desired : __MEMCHUNK__;

	if(!(CURPROC.bookbase = do_sbrk(more)))
	{
		if(!(CURPROC.bookbase = do_sbrk(desired)))
		{
		  if(CURPROC.bookreserve[0] == 12345)
		  {
			return 0;	/* OUT OF BOOKKEEPING SPACE */
		  }
		  else
		  {
			CURPROC.bookreserve[0] = 12345;
			CURPROC.bookbase = (char*)&CURPROC.bookreserve[1];
			CURPROC.booksize = 12288;
			VNOTICE("OXMALLOC: WARNING memory is VERY VERY low");
		  }
		}
		else
		{
			VNOTICE("OXMALLOC: WARNING memory is low");
			CURPROC.booksize = desired;
		}
	}
	else CURPROC.booksize = more;
	return 1;
}
static void *
new_book_chunk(unsigned size)
{
char *p;

	if(CURPROC.booksize < size)
	{/* this algorithm throws away small amounts of unused space */
		if(!get_bookspace(PAGESIZE))
			return 0;
	}
	CURPROC.booksize -= size;
	p = CURPROC.bookbase;
	CURPROC.bookbase += size;
	return p;
}
static struct _catlocs *
new_catloc(void)
{
struct _catlocs *p;
	if((p=CURPROC.freecatlocs))
	{
		CURPROC.freecatlocs = p->fptr;
		return p;
	}
	return (struct _catlocs *)new_book_chunk(sizeof(struct _catlocs));
}
static void
free_catloc(struct _catlocs *p)
{
	p->fptr = CURPROC.freecatlocs;
	CURPROC.freecatlocs = p;
}
static void *
new_Mnode(int levels)
{
unsigned size;
NodePM p;

	if((p=CURPROC.freenodes[levels]))
	{
		CURPROC.freenodes[levels] = p->fptr[0];
		p->value = 0;
		return p;
	}
	size = sizeof(struct _nodeM) + levels * sizeof(void*);
	if((p = (NodePM)new_book_chunk(size)))
	{
		p->levels = levels;
		p->value = 0;
	}
	else
	{/* running out of space -- try to allocate from pool of larger nodes */ 
		while(++levels <= MAL_MAXLEVEL)
		{
			if((p=CURPROC.freenodes[levels]))
			{
				CURPROC.freenodes[levels] = p->fptr[0];
				p->value = 0;
				break;
			}
		}
	}
	return p;	
}
static void
free_Mnode(NodePM p)
{
	if(p)
	{
		p->fptr[0] = CURPROC.freenodes[p->levels];
		CURPROC.freenodes[p->levels] = p;
	}
}
static struct _addr *
new_addr(void)
{
struct _addr *p;

	if((p=CURPROC.freeaddrlocs))
	{
		CURPROC.freeaddrlocs = p->fptr;
		return p;
	}
	return (struct _addr *)new_book_chunk(sizeof(struct _addr));
}
static void
free_addr(AddrP p)
{
	if(p)
	{
		p->fptr = CURPROC.freeaddrlocs;
		CURPROC.freeaddrlocs = p;
	}
}
static struct _bins *
new_bins(void)
{
struct _bins *p;

	if((p=CURPROC.freebinlocs))
	{
		CURPROC.freebinlocs = p->fptr;
		return p;
	}
	return (struct _bins *)new_book_chunk(sizeof(struct _bins));
}
static void
free_bins(struct _bins *p)
{
	if(p)
	{
		p->fptr = CURPROC.freebinlocs;
		CURPROC.freebinlocs = p;
	}
}
static int
getMlevel (struct _bins *p, int binlevel)
{
int level = -1;
int bits = 0;

	while(bits == 0)
	{
		if (p->nbits == 0)
		{
			p->bits = lrandom();
			p->nbits = 15;
		}
		bits = p->bits & 3;
		p->bits >>= 2;
		p->nbits--;

		if(++level > binlevel)
			break;
	}
	return (level > MAL_MAXLEVEL) ? MAL_MAXLEVEL : level;
}

static void
init_bins(struct _bins *bp, int heapnum)
{
int i;
int binnum = heapnum % 1009;

	memset(bp, 0, sizeof(struct _bins));
	bp->bincat = heapnum;
	bp->minloc = 0xffffffff;
	bp->fptr = CURPROC.hmap[binnum];
	CURPROC.hmap[binnum] = bp;
	bp->SIZEHheader = new_Mnode(MAL_MAXLEVEL+1);
	bp->FREEHheader = new_Mnode(MAL_MAXLEVEL+1);
	bp->USEDHheader = new_Mnode(MAL_MAXLEVEL+1);

	for(i = 0; i <= MAL_MAXLEVEL; ++i)
	{
		bp->SIZEHheader->fptr[i] = _NILLL;
		bp->FREEHheader->fptr[i] = _NILLL;
		bp->USEDHheader->fptr[i] = _NILLL;
	}
}

static struct _bins*
getcat(int heapnum)
{
struct _bins *hbp;

	hbp = CURPROC.hmap[heapnum % 1009];
	while(hbp)
	{
		if(hbp->bincat == heapnum)
			return hbp;
		hbp = hbp->fptr;
	}
	return 0;
}
static struct _bins *
initcat(int heapnum)
{
struct _bins *bp;

	if(heapnum == 0)
	{
		bp = &CURPROC.zbp;
		if(CURPROC.zbp.SIZEHheader == 0)
			init_bins(bp, heapnum);
	}
	else
	{/* check if heapnum 0 has been initialized */
	  if(CURPROC.zbp.SIZEHheader == 0)
		initcat(0);

	  if((bp = new_bins()))
	    init_bins(bp, heapnum);
	}
	return bp;
}
static void *
getspace(struct _bins *bp, unsigned size, unsigned *remainder)
{
unsigned desired;
void *address;
  
	if(bp->bincat == 0)
	{
	  desired = ((size+__MEMCHUNK__-1)/__MEMCHUNK__)*__MEMCHUNK__;
	  if(!(address = do_sbrk(desired)))
	  {
		desired = size;
		if(!(address = do_sbrk(desired)))
			return 0; /* OUT OF USER SPACE */
		else
		  VNOTICE("OXMALLOC: WARNING memory is low");
	  }
	  *remainder = desired - size;
	}
	else
	{
	struct _catlocs *cl;

		desired = ((size+ALLOCSIZE-1)/ALLOCSIZE)*ALLOCSIZE;
		if((int)(desired-size) > CURPROC.zbp.guarded)
			desired -= CURPROC.zbp.guarded;
		
		if(!(address = mallocH(0, desired)))
			return 0; /* OUT OF USER SPACE */

		/* save the gross allocations for the heapnum */
		if(!(cl = new_catloc()))
		{
			freeH(0, address);
			return 0; /* OUT OF BOOKKEEPING SPACE */
		}
		cl->addr = address;
		cl->fptr = bp->catlocs;
		bp->catlocs = cl;

		*remainder = desired - size;
	}
	/* maintain address range info */
	bp->totalloc += desired;
	if((unsigned)address < bp->minloc)
		bp->minloc = (unsigned)address;
	if(((unsigned)address + desired) > bp->maxloc)
		bp->maxloc = (unsigned)address + desired;	
	if(bp->minloc < CURPROC.minloc)
		CURPROC.minloc = bp->minloc;
	if(bp->maxloc > CURPROC.maxloc)
		CURPROC.maxloc = bp->maxloc;
	return address;
}
static int
addto_sizelist(struct _bins *bp, AddrP ap)
{
SKIPVARS;

	/* INSERT IN SIZE LIST */
	FINDKEY(SIZEH, ap->size)

	if(node->key == ap->size)
	{/* size node exists */
		ap->fptr = (AddrP)node->value;
		ap->bptr = (AddrP)&node->value;
		if(ap->fptr) ap->fptr->bptr = ap;
		node->value = (unsigned)ap;
	}
	else
	{/* create new size node */
		SETLEVEL(SIZEH)
		if(!(node = new_Mnode(level)))
			return 0;	/* OUT OF BOOKKEEPING SPACE */
		node->key = ap->size;
		node->value = (unsigned)ap;
		ap->fptr = 0;
		ap->bptr = (AddrP)&node->value;
		INSERT()
	}
	return 1;
}
static int
addto_freelist(struct _bins *bp, void *addr, unsigned size)
{
SKIPVARS;
AddrP ap,sp;
unsigned dsize[2];

	/* GET NEW ADDR STRUCT */
	if(!(ap = new_addr()))
		return 0; /* OUT OF BOOKKEEPING SPACE */
	ap->size = size;

	dsize[1] = dsize[0] = 0; /* sizenode deletion markers */

	/* CHECK FREE LIST */
	FINDKEY(FREEH, (unsigned)addr)

	/* CHECK FOR MERGE OR INSERT */
	if(prev->value && prev->key+((AddrP)prev->value)->size == (unsigned)addr)
	{/* merge with previous block */
		ap->size += ((AddrP)prev->value)->size;

		if(prev->key + ap->size == node->key)
		{/* merge with previous and next block */
			sp = (AddrP) node->value;;
			ap->size += sp->size;

			/* delete size struct for next block */
			UNLINK(sp, 0)

			/* delete next block */
			DELETENODE(FREEH);
		}
		/* delete size struct for prev block */
		sp = (AddrP)prev->value;
		UNLINK(sp, 1)

		/* set new address struct */
		prev->value = (unsigned)ap;
		ap->maddr = prev;
	}
	else if(node->value && (char*)addr + size == (void*)node->key)
	{/* merge with next block */
		sp = (AddrP) node->value;;
		node->key = (unsigned)addr;
		ap->size += sp->size;

		/* unlink size struct for next block */
		UNLINK(sp,0)

		/* set new address struct */
		node->value = (unsigned)ap;
		ap->maddr = node;
	}
	else
	{/* insert in free list */

		SETLEVEL(FREEH)
		if(!(node = new_Mnode(level)))
			return 0;
		node->key = (unsigned)addr;
		node->value = (unsigned)ap;
		ap->maddr = node;
		INSERT()
	}
#if 0
	if(!addto_sizelist(bp, ap))
		return 0;
#endif
	/* Remove sizenodes eliminated by merge */
	if(dsize[0])
	{
		FINDKEY(SIZEH, dsize[0])
		if(node->value == 0)
		  DELETENODE(SIZEH)
	}
	if(dsize[1])
	{
		FINDKEY(SIZEH, dsize[1])
		if(node->value == 0)
		  DELETENODE(SIZEH)
	}
#if 1
	if(!addto_sizelist(bp, ap))
		return 0; /* OUT OF BOOKKEEPING SPACE */
#endif
	return 1;
}

void* 
memalignH(int heapnum, unsigned alignment, unsigned req)
{
SKIPVARS;
NodePM fnode;
unsigned remainder;
unsigned *address;
struct _bins *bp;
unsigned mask, size;

	if(!(bp = getcat(heapnum)))
	  if(!(bp = initcat(heapnum)))
		return 0;

	if(CURPROC.mem_bug-1 == heapnum)
		HEAPCHECK

	if(req == 0)
		req = ALIGNMENTM; /* allow user to validly allocate zero bytes */
	else
		req = ROUNDINGM(req);
	size = req += bp->guarded;

	if(alignment)
	{
		alignment = ROUNDINGM(alignment);
		if(alignment > ALIGNMENTM)
		{
			mask = alignment -1;
			size = req + alignment + bp->guarded;
		}
		else
		{
			alignment = 0;
		}
	}
	/* check sizelist for candidate */
	FINDKEY(SIZEH, size)
	fnode = node;
trynext:
	if(node->key != 0xffffffff)
	{/* found an appropriately sized block */
	AddrP sp = (AddrP)node->value;

		if(!sp && node == fnode)
		{
		NodePM q;
			q = node->fptr[0];
			DELETENODE(SIZEH)
			node = q;
			goto trynext;
		}
		if(!sp)
		{/* no available space at this size */
			node = node->fptr[0];
			goto trynext;
		}
		/* extract some space from this block */
		remainder = node->key - size;
		address = (void*)sp->maddr->key;
		sp->maddr->key += size;
		DETACH(sp);

		if(node->value == 0)
		{/* no more blocks of this size, delete sizenode */
			if(node != fnode)
			  FINDKEY(SIZEH, size)
			DELETENODE(SIZEH)
		}

		if(remainder == 0)
		{/* no remaining space,the node in freelist is exhausted, delete it */
			FINDKEY(FREEH, sp->maddr->key)
			DELETENODE(FREEH)
			free_addr(sp);
		}
		else
		{/* space remains in block, move it to new size loc */
			sp->size = remainder;
			addto_sizelist(bp, sp);
		}
	}
	else
	{
		if(!(address = getspace(bp, size, &remainder)))
			return 0;
		if(remainder)
		  addto_freelist(bp, ((char*)address)+size, remainder);
	}
	if(alignment)
	{
	unsigned diff;
		if((diff = (unsigned)address & mask))
		{/* move address forward */
		char *naddress;
		unsigned lose;
			lose = alignment - diff;
			naddress = (char*)address + lose;
			addto_freelist(bp, address, lose);
			address = (unsigned*)naddress;
		}
	}
	if(bp->guarded)
	{
	  *address = FRNTGUARD;
	  *((unsigned*)(((char*)address)+req-GUARDSIZE)) = BACKGUARD;
	}

	/* Insert in Used List */
	FINDKEY(USEDH, (unsigned)address)
	if(node->key == (unsigned)address)
	  VCRASH("OXMALLOC:%d: bookkeeping corrupted at:0x%p\n",heapnum, address);
	SETLEVEL(USEDH)
	if((node = new_Mnode(level)))
	{
		node->key = (unsigned)address;
		node->value = req;
		INSERT()	
	}

	bp->usedalloc += size;
	return address+bp->addrbump;
}
void*
callocH(int heapnum, unsigned cnt, unsigned elem_size)
{
unsigned size = cnt * elem_size;
void* buf;;

  if((buf = mallocH(heapnum, size)))
	  memset(buf, 0, size);
  return buf;
};
void
freeH(int heapnum, void* addr)
{
unsigned cursize;
unsigned *address;
struct _bins *bp;
SKIPVARS;

	if(addr && (bp = getcat(heapnum)))
	{
		if(CURPROC.mem_bug-1 == heapnum)
			HEAPCHECK
		address = (void*) ((unsigned*)addr - bp->addrbump);
		FINDKEY(USEDH, (unsigned)address)
		if(node->key != (unsigned)address)
		  VCRASH("freeC:%d: bogus address=0x%p\n", heapnum, addr);

		cursize = node->value;
		CHECKGUARDS(freeC)
		DELETENODE(USEDH)

		bp->usedalloc -= cursize;
		addto_freelist(bp, address, cursize);
	}
#if PICKY_ABOUT_NULL_POINTERS
	else VCRASH("freeC:%d:%p: bogus heapnum or null pointer\n", heapnum,addr);
#endif
}
void* 
reallocH(int heapnum, void* addr, unsigned newsize)
{
SKIPVARS;
unsigned cursize;
unsigned *address;
struct _bins *bp;
NodePM onode;

	if(!(bp = getcat(heapnum)))
		VCRASH("reallocC:%d: bogus heapnum, address=0x%p\n", heapnum, addr);
	if(addr)
	{		
		if(newsize == 0)
		{
			freeH(heapnum, addr);
			return NULL;
		}
		if(CURPROC.mem_bug-1 == heapnum)
			HEAPCHECK

		if(newsize == 0)
			newsize = ALIGNMENTM;
		else
			newsize = ROUNDINGM(newsize);
		newsize += bp->guarded;

		address = (void*)(((char*)addr)-(bp->guarded/2));
		FINDKEY(USEDH, (unsigned)address)
		if(node->key != (unsigned)address)
		  VCRASH("reallocC:%d: bogus address=0x%p\n", heapnum, addr);

		cursize = node->value;
		node->value = newsize;
		onode = node;

		CHECKGUARDS(reallocC)

		if(newsize == cursize)
			return addr;
		if(newsize > cursize)
		{/* check if block can be extended */
		void *taddr = ((char*)address) + cursize;
		unsigned extendsize = newsize-cursize;

		  /* check freelist for an available block at the right address */
		  FINDKEY(FREEH, (unsigned)taddr)
		  if(node->key == (unsigned)taddr)
		  {
		  AddrP sp = (AddrP)node->value;
			if(sp->size >= extendsize)
			{/* BLOCK CAN BE EXTENDED INTERNALLY */
			  node->key += extendsize;
			  bp->usedalloc += extendsize;
			  sp->size -= extendsize;
			  DETACH(sp)
			  if(sp->size == 0)
			  {/* the extension block is used up, delete this node */
				free_addr(sp);
				DELETENODE(FREEH)
			  }
			  else
			  {/* shift the remainder in the sizelist */
				addto_sizelist(bp, sp);
			  }
			  /* INTERNAL SUCCESS */
			  if(bp->guarded)
				*((unsigned*)(((char*)address)+newsize-GUARDSIZE)) = BACKGUARD;
			}
		  }
		  else if((taddr = mallocH(heapnum,newsize-bp->guarded)))
		  {/* Can't extend block, malloc some new space */
			memcpy(taddr,addr,cursize-bp->guarded);
			onode->value = cursize;
			freeH(heapnum, addr);
			addr = taddr;
		  }
		  else addr = 0;
		  if(bp->realloc_clr && addr)
			memset(((char*)addr)+cursize-bp->guarded,0,newsize-cursize);
		} /* newsize > cursize */
		else
		{/* shrink block */
		  if(bp->guarded)
			*((unsigned*)(((char*)address)+newsize-GUARDSIZE)) = BACKGUARD;
		  addto_freelist(bp, ((char*)address)+newsize, cursize-newsize); 
		  bp->usedalloc -= cursize-newsize;
		}
	}
	else
	{/* realloc of NULL address, do a malloc */
		if((addr = mallocH(heapnum, newsize)))
		{
			if(bp->realloc_clr)
			  memset(addr,0,newsize);
		}
	}
	return addr;
}
void
freeheap(int heapnum)
{
struct _bins *bp;

	if(heapnum == 0)
		return;

	if((bp = getcat(heapnum)))
	{
	struct _catlocs *cl = bp->catlocs;
	struct _bins *hbp, *prev;
	NodePM node, qnode;

		/* Space allocated to the heapnum is moved to heapnum 0 */

		while(cl)
		{
		void *ql = cl->fptr;
			freeH(0, cl->addr);
			free_catloc(cl);
			cl = ql;
		}
		/* the skip list structs are placed on free lists */

		node = bp->FREEHheader;
		while(node != _NILLL)
		{
			qnode = node->fptr[0];
			free_addr((AddrP)node->value);
			free_Mnode(node);
			node = qnode;
		}

		node = bp->SIZEHheader;
		while(node != _NILLL)
		{
			qnode = node->fptr[0];
			free_Mnode(node);
			node = qnode;
		}

		node = bp->USEDHheader;
		while(node != _NILLL)
		{
			qnode = node->fptr[0];
			free_Mnode(node);
			node = qnode;
		}

		/* space for the _bins struct is placed on a free list */
		hbp = CURPROC.hmap[heapnum % 1009];
		prev = 0;
		while(hbp)
		{
			if(hbp->bincat == heapnum)
			{
				if(prev == 0)
					CURPROC.hmap[heapnum % 1009] = hbp->fptr;
				else
					prev->fptr = hbp->fptr;
				free_bins(hbp);
				return;
			}
			prev = hbp;
			hbp = hbp->fptr;
		}
	}
}
int
memrangeH(int heapnum, unsigned *min, unsigned *max)
{
struct _bins *bp;

	if(min && max && (bp = getcat(heapnum)))
	{
		*min = bp->minloc;
		*max = bp->maxloc;
		return 1;
	}
	return 0;
}
int
usedrangeH(int heapnum, unsigned *min, unsigned *max)
{
struct _bins *bp;
NodePM node;
int level;

	if(min && max && (bp = getcat(heapnum)))
	{
		node = bp->USEDHheader;
		*min = node->fptr[0]->key;
		for(level = bp->USEDHlevel; level >= 0; level--)
		  while(node->fptr[level]->key < 0xffffffff)
			node = node->fptr[level];
		*max = node->key;
		return 1;
	}
	return 0;
}
void
totrangeH(unsigned *min, unsigned *max)
{
	if(min && max)
	{
		*min = CURPROC.minloc;
		*max = CURPROC.maxloc;
	}
}
void
howmuchH(int heapnum, unsigned *tot, unsigned *used)
{
struct _bins *bp;

	if(tot && used)
	{
	  if(bp = getcat(heapnum))
	  {
		*tot = bp->totalloc;
		*used = bp->usedalloc;
	  }
	  else
	  {
		*tot = 0;
		*used = 0;
	  }
	}
}
void
guardH(int heapnum)
{
struct _bins *bp;

	if(!(bp = getcat(heapnum)))
	  if(!(bp = initcat(heapnum)))
		  return;

	if(!bp->guarded)
	{
		bp->guarded = 2*GUARDSIZE;
		bp->addrbump = 1;
	}
}
void
setReallocClr(int heapnum)
{
struct _bins *bp;

	if(!(bp = getcat(heapnum)))
	  if(!(bp = initcat(heapnum)))
		  return;
	bp->realloc_clr = 1;
}
void*
heapcheckH(int heapnum, void *start)
{
struct _bins *bp;
NodePM node,prev;
unsigned *p1,*p2;

	if((bp = getcat(heapnum)))
	{
		if(bp->guarded)
		{
			prev = 0;
			node = bp->USEDHheader;
			while(		(node = node->fptr[0]) != (NodePM)0xffffffff
					&&	node->key != 0xffffffffUL)
			{
				if((void*)node->key > start)
				{
					p1 = (unsigned*)node->key;
					if(*p1 != FRNTGUARD)
					{
						if(prev)
							return (char*)prev->key+GUARDSIZE;
						else
							return (void*)1;
					}
					p2 = (unsigned*)(((char*)p1)+node->value-GUARDSIZE);
					if(*p2 != BACKGUARD)
						return (char*)node->key+GUARDSIZE;
				}
				prev = node;
			}
		}
	}
	return 0;
}
void* 
mallocH(int heapnum, unsigned size)
{
	return memalignH(heapnum, 0, size);
}

void* 
vallocH(int heapnum, unsigned bytes)
{
  return memalignH(heapnum, PAGESIZE, bytes);
}
unsigned
mallocsizeH(int heapnum, void* addr)
{
struct _bins *bp;
SKIPVARS;

	if(addr && (bp = getcat(heapnum)))
	{
	unsigned address = (unsigned)((unsigned*)addr - bp->addrbump);
		FINDKEY(USEDH, address)
		if(node->key == address)
			return node->value - bp->guarded;
	}
	return 0;
}

int
NewMallocHeap(void)
{
	return ++CURPROC.cat;
}
void heapMembug(int heapnum)
{
	CURPROC.mem_bug = heapnum+1;
	guardH(heapnum);
}
/* ====================== END MULTI-HEAP MALLOC ============================ */


#if defined(_MSC_VER) && !defined(_DEBUG)

/* These are here to substitue for the system malloc  */

void *
malloc(size_t a)
{
	return mallocH(BASE_HEAP, a);
}
void
free(void *a)
{
	freeH(BASE_HEAP,a);
}
void *
realloc(void *a, size_t b)
{
	return reallocH(BASE_HEAP,a,b);
}
void *
calloc(size_t a, size_t b)
{
	return callocH(BASE_HEAP,a,b);
}
void *
valloc(size_t a)
{
	return vallocH(BASE_HEAP,a);
}
void *
memalign(unsigned a, unsigned b)
{
	return	memalignH(BASE_HEAP,a,b);
}
unsigned
mallocsize(void *a)
{
	return mallocsizeH(BASE_HEAP, a);
}

/* microsoft specials */
int
_heapadd(void *memblk, unsigned size)
{
	return -1;
}
int
_heapchk(void)
{
	return -1;
}
int
_heapmin(void)
{
	return -1;
}
int
_heapset(unsigned fill)
{
	return 0;
}
#ifndef _MSC_VER
#define _HEAPINFO void
#endif
int
_heapwalk(_HEAPINFO *info)
{
	return 0;
}
#endif /* _MSC_VER */

/* ======================= CODE FOR TESTING ========================== */
#ifdef TEST
#include <time.h>

#ifdef UCLOCKS_PER_SEC
#define CLOCK uclock
#define CLOCK_T uclock_t
#undef CLK_TCK
#define CLK_TCK UCLOCKS_PER_SEC
#else
#define CLOCK clock
#define CLOCK_T clock_t
#endif

#define ITERATIONS 0x20000 /* must have one bit and trailing zeros */
#define MAXALLOC 0x1ff
#define MALLOC(a) mallocH(1,a)
#define FREE(a) freeH(1,a)
#define REALLOC(a,b) reallocH(1,a,b)

#define PRINT_TIME(string) \
diff = (double)(end - start);\
diff /= (double)CLK_TCK;\
if(diff == 0.0) diff = 1.0;\
printf(string " = %8.1f\n", (double)i / diff);\
howmuchH(1, &tot, &used);\
printf("Category 1 allocated:%u used:%u free:%u\n", tot, used, tot-used);\
howmuchH(0, &tot, &used);\
printf("Category 0 allocated:%u used:%u free:%u\n", tot, used, tot-used);\
printf("SBRK allocated:%u\n", CURPROC.tot_alloc);

#define DEBUG_STATISTICS
#define DEBUG_USEDNODES
static void
print_freenodes(int heapnum)
{
int i;
NodePM node;
AddrP ap;
struct _bins *bp = getcat(heapnum);

#ifdef DEBUG_STATISTICS
	printf("SIZENODES\n");
	node = bp->SIZEHheader;
	while((node = node->fptr[0]))
	{
		printf("Size:%d\n", node->key);
		ap = (AddrP)node->value;
		while(ap)
		{
			printf("	%x	size=%d\n", ap->maddr->key, ap->size);
			ap = ap->fptr;
		}
	}
	printf("FREENODES\n");
	node = bp->FREEHheader;
	while((node = node->fptr[0]))
	{
	int size;
		if((ap = (AddrP)node->value))
			size = ap->size;
		else size=-1;

		printf("Addr:%x	size=%d=0x%x End:%x\n",
			node->key, size, size, node->key+size);
	}
#ifdef DEBUG_USEDNODES
	printf("USEDNODES\n");
	node = bp->USEDHheader;
	while((node = node->fptr[0]))
	{
		printf("Addr:0x%x	Size:%d\n", node->key, node->value);
	}
#endif
#ifdef DEBUG_SPARES
	printf("SPARES\n");
	for(i = 0; i <= MAXLEVEL; ++i)
		printf("%d	%d\n", i, histnodes[i]);
#endif
#endif
}

int
main(int argc, char **argv)
{
int i;
void *buf;
unsigned tot, used;
CLOCK_T start, end;
double diff;
unsigned tot_req = 0;
static void *addrs[ITERATIONS];
static unsigned randval[ITERATIONS];

	printf("PRE MAIN ALLOCATIONS VIA CALLS TO MALLOC\n");
	howmuchH(1, &tot, &used);
	printf("Category 1 allocated:%u used%u free%u\n", tot, used, tot-used);
	howmuchH(0, &tot, &used);
	printf("Category 0 allocated:%u used%u free%u\n", tot, used, tot-used);
	printf("SBRK allocated:%u\n", CURPROC.tot_alloc);


	for(i = 0; i < ITERATIONS; ++i)
	{
		randval[i] = lrandom();
		addrs[i] = 0;
	}

	start = CLOCK();
	for(i = 0; i < ITERATIONS; ++i)
	{
		addrs[i] = MALLOC(randval[i] & MAXALLOC);
		tot_req += randval[i] & MAXALLOC;
	}
	end = CLOCK();
	PRINT_TIME("MALLOC PER SEC")
	printf("User requested %u bytes\n", tot_req);

	start = CLOCK();
	/* Free the addresses in random order */
	for(i = 0; i < ITERATIONS; ++i)
	{
	int j = randval[i] & (ITERATIONS-1);
		if(addrs[j])
		{
			FREE(addrs[j]);
			addrs[j] = 0;
		}
	}
	/* Clean up any missed elements */
	for(i = 0; i < ITERATIONS; ++i)
	{
		if(addrs[i])
		{
			FREE(addrs[i]);
			addrs[i] = 0;
		}
	}
	end = CLOCK();
	PRINT_TIME("FREE PER SEC")

	start = CLOCK();
	for(i = 0; i < ITERATIONS; ++i)
	{
	int j = randval[i] & (ITERATIONS-1);
		addrs[i] = MALLOC(j & MAXALLOC);
		if(j < i && addrs[j])
		{
			FREE(addrs[j]);
			addrs[j] = 0;
		}
	}
	end = CLOCK();
	PRINT_TIME("COMBO PER SEC");

	/* Cleanup */
	for(i = 0; i < ITERATIONS; ++i)
	{
		if(addrs[i])
		{
			FREE(addrs[i]);
			addrs[i] = 0;
		}
	}
	start = CLOCK();
	for(i = 0; i < ITERATIONS/2; ++i)
	{
	int j = randval[i] & ((ITERATIONS/2)-1);

		addrs[i] = MALLOC(randval[i] & MAXALLOC);
		*((unsigned*)addrs[i]) = randval[i];

		if(j < i && addrs[j])
		{
			if(*((unsigned*)addrs[j]) != randval[j])
			  printf("malloc: fail i=%d j=%d addr=0x%x des=%x got=%x size=%d\n",
				i, j, addrs[j], randval[j], *((unsigned*)addrs[j]), 
				randval[j] & MAXALLOC);

			addrs[j] = REALLOC(addrs[j], randval[i] & MAXALLOC);
			 if(*((unsigned*)addrs[j]) != randval[j])
			  printf("realloc: fail i=%d j=%d addr=0x%x des=%x got=%x nsize=%d\n",
				i, j, addrs[j], randval[j], *((unsigned*)addrs[j]), 
				randval[i] & MAXALLOC);
		}
	}
	end = CLOCK();
	PRINT_TIME("REALLOC PER SEC");

	freeheap(1);
	printf("\nAFTER FREECAT OF CATEGORY 1\n");
	howmuchH(1, &tot, &used);
	printf("Category 1 allocated:%u used:%u free:%u\n", tot, used, tot-used);
	howmuchH(0, &tot, &used);
	printf("Category 0 allocated:%u used:%u free:%u\n", tot, used, tot-used);

	return 0;
}
#endif /* TEST */



--------------33FA6A6F2354--
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
