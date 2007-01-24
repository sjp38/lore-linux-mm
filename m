Date: Wed, 24 Jan 2007 14:15:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Limit the size of the pagecache
Message-Id: <20070124141510.7775829c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0701232028520.6820@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
	<20070124121318.6874f003.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0701232028520.6820@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: aubreylee@gmail.com, svaidy@linux.vnet.ibm.com, nickpiggin@yahoo.com.au, rgetz@blackfin.uclinux.org, Michael.Hennerich@analog.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Jan 2007 20:30:16 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 24 Jan 2007, KAMEZAWA Hiroyuki wrote:
> 
> > I don't prefer to cause zone fallback by this.
> > This may use ZONE_DMA before exhausing ZONE_NORMAL (ia64),
> 
> Hmmm... We could use node_page_state instead of zone_page_state.
> 
> > Very rapid page allocation can eats some amount of lower zone.
> 
> One queston: For what purpose would you be using the page cache size 
> limitation?
> 
This is my experience in support-desk for RHEL4. 
(therefore, this may not be suitable for talking about the current kernel)

- One for stability
  When a customer constructs their detabase(Oracle), the system often goes to oom.
  This is because that the system cannot allocate DMA_ZOME memory for 32bit device.
  (USB or e100)
  Not allowing to use almost all pages as page cache (for temporal use) will be some help.
  (Note: construction DB on ext3....so all writes are serialized and the system couldn't
   free page cache.)

- One for tuing.
  Sometimes our cutomer requests us to limit size of page-cache.
  
  Many cutomers's memory usage reaches 99.x%. (this is very common situation.)
  If almost all memories are used by page-cache, and we can think we can free it.
  But the customer cannot estimate what amount of page-cache can be freed (without 
  perfromance regression).
  
  When a cutomer wants to add a new application, he tunes the system.
  But memory usage is always 99%.
  page-cache limitation is useful when the customer tunes his system and find
  sets of data and page-cache. 
  (Of course, we can use some other complicated resource management system for this.)
  This will allow the users to decide that they need extra memory or not.

  And...some customers want to keep memory Free as much as possible.
  99% memory usage makes insecure them ;)

-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
