Date: Wed, 2 Jan 2008 12:45:43 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.22-stable causes oomkiller to be invoked
In-Reply-To: <20071228101109.GB5083@linux.vnet.ibm.com>
Message-ID: <Pine.LNX.4.64.0801021237330.21526@schroedinger.engr.sgi.com>
References: <20071214150533.aa30efd4.akpm@linux-foundation.org>
 <20071215035200.GA22082@linux.vnet.ibm.com> <20071214220030.325f82b8.akpm@linux-foundation.org>
 <20071215104434.GA26325@linux.vnet.ibm.com> <20071217045904.GB31386@linux.vnet.ibm.com>
 <Pine.LNX.4.64.0712171143280.12871@schroedinger.engr.sgi.com>
 <20071217120720.e078194b.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0712171222470.29500@schroedinger.engr.sgi.com>
 <20071221044508.GA11996@linux.vnet.ibm.com>
 <Pine.LNX.4.64.0712261258050.16862@schroedinger.engr.sgi.com>
 <20071228101109.GB5083@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, htejun@gmail.com, gregkh@suse.de, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Balbir Singh <balbir@in.ibm.com>, maneesh@linux.vnet.ibm.com, lkml <linux-kernel@vger.kernel.org>, stable@kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 28 Dec 2007, Dhaval Giani wrote:

> we managed to get your required information. Last 10,000 lines are
> attached (The uncompressed file comes to 500 kb).
> 
> Hope it helps.

Somehow the nr_pages field is truncated to 16 bit and it 
seems that there are sign issues there? We are wrapping around....

 q->nr_pages is 36877, min_pages is 25 ----> swapper
 q->nr_pages is 46266, min_pages is 25 ----> bash
 q->nr_pages is 36877, min_pages is 25 ----> swapper
 q->nr_pages is 36877, min_pages is 25 ----> swapper
 q->nr_pages is 46265, min_pages is 25 ----> bash
 q->nr_pages is 46265, min_pages is 25 ----> cat
 q->nr_pages is 36877, min_pages is 25 ----> swapper
 q->nr_pages is 46265, min_pages is 25 ----> cat
 q->nr_pages is 36877, min_pages is 25 ----> swapper
 q->nr_pages is 0, min_pages is 25 ----> swapper
 q->nr_pages is 36877, min_pages is 25 ----> swapper
 q->nr_pages is 36877, min_pages is 25 ----> swapper
 q->nr_pages is 46265, min_pages is 25 ----> cat


An int is just a 16 bit field on i386? I thought it was 32 bits? Or is 
the result due to the way that systemtap works?

Could you post the neighboring per cpu variables to quicklist (look at the 
System.map). Maybe somehow we corrupt the nr_pages and page contents.

Also could you do another systemtap and also print out the current 
processor? Maybe nr_pages gets only corrupted on a specific processor. I 
see a zero there and sometimes other sane values.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
