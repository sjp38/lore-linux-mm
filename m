Message-Id: <200105082051.f48KpTx08708@maila.telia.com>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: [RFC] alternative swap_amount
Date: Tue, 8 May 2001 22:48:46 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Hi again,

Got some time to spend...

I wonder about the fairness in swap_amount (mm/vmscan.c)
Suppose you have a small process with
	mm->rss <= SWAP_MIN
then swap_amount will 
	return SWAP_MIN

Resulting in an attempt to swap out ALL pages of that process.
And if it had less pages even claim that we did not succeed...???

Shouldn't the return value at least be limited by the actual number
of pages in the mm?

Rules:
	0 -> 0 (if there are no pages anyway..., must be handled)
	low -> P% of low (but require that we will finally get 0 pages left)
	high -> p% of high

One, _untested_ example, would be:

static inline int swap_amount(struct mm_struct *mm)
{
	/* begin with high, I have slightly more big than small ? */
	int nr = mm->rss >> SWAP_SHIFT;
	if (nr < SWAP_MIN) {
		nr = (mm->rss + 1) / 2; /* 0 => 0, 1 => 1, 2 => 1, 3 => 2 */
 		if (nr > SWAP_MIN)
			nr = SWAP_MIN;
	}
	return nr;
}

Compare these outputs:
rss	_old	_new
        0               8               0
        1               8               1
        2               8               1
        4               8               2
        8               8               4
       16               8               8
       32               8               8
       64               8               8
      128               8               8
      256               8               8
      512              16              16
     1024              32              32
     2048              64              64
     4096             128             128

/RogerL

---- original code ----
#define SWAP_SHIFT 5
#define SWAP_MIN 8

static inline int swap_amount(struct mm_struct *mm)
{
	int nr = mm->rss >> SWAP_SHIFT;
	return nr < SWAP_MIN ? SWAP_MIN : nr;
}

static int swap_out(unsigned int priority, int gfp_mask)
{
	int counter;
	int retval = 0;
	struct mm_struct *mm = current->mm;

	/* Always start by trying to penalize the process that is allocating memory*/
	if (mm)
		retval = swap_out_mm(mm, swap_amount(mm));

-- 
Roger Larsson
Skelleftea
Sweden
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
