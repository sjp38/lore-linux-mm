Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: how not to write a search algorithm
Date: Mon, 5 Aug 2002 02:03:27 +0200
References: <3D4CE74A.A827C9BC@zip.com.au> <E17bU7n-0000Yb-00@starship> <3D4DB2AF.48B07053@zip.com.au>
In-Reply-To: <3D4DB2AF.48B07053@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17bVLM-0000bq-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 05 August 2002 01:03, Andrew Morton wrote:
> The list walk is killing us now.   I think we need:
> 
> struct pte_chain {
> 	struct pte_chain *next;
> 	pte_t *ptes[L1_CACHE_BYTES/4 - 4];
> };

Strongly agreed.  A full 64 bytes might be a little much though.  Let me see, 
for 32 bytes the space breakeven is 4X sharing, for 64 bytes it's 8X and 
we'll rarely hit that, except in contrived benchmarks.

A variation on this idea makes the size of the node a property of an antire 
page's worth of nodes, so that nodes of different sizes can be allocated.  
The node size can be recorded at the base of the page, or in a vector of 
pointers to such pages.  Moving from size to size is by copying rather than 
list insertion, and only the largest size needs a list link.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
