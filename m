From: Wang Xiaoqiang <wangxq10@lzu.edu.cn>
Subject: Re: [PATCH] memory_failure: remove redundant check for the
 PG_HWPoison flag of 'hpage'
Date: Thu, 30 Jul 2015 10:52:46 +0800
Message-ID: <20150730105246.6bcc0af5@hp>
References: <20150729155246.2fed1b96@hp>
	<20150729091725.GA1256@hori1.linux.bs1.fc.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150729091725.GA1256@hori1.linux.bs1.fc.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

On Wed, 29 Jul 2015 09:17:32 +0000
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> # CC:ed linux-mm
> 
> Hi Xiaoqiang,
> 
> On Wed, Jul 29, 2015 at 03:52:46PM +0800, Wang Xiaoqiang wrote:
> > Hi,
> > 
> > I find a little problem in the memory_failure function in
> > mm/memory-failure.c . Please check it.
> > 
> > memory_failure: remove redundant check for the PG_HWPoison flag of
> > `hpage'.
> > 
> > Since we have check the PG_HWPoison flag by `PageHWPoison' before,
> > so the later check by `TestSetPageHWPoison' must return true, there
> > is no need to check again!
> 
> I'm afraid that this TestSetPageHWPoison is not redundant, because
> this code serializes the concurrent memory error events over the same
> hugetlb page (, where 'p' indicates the 4kB error page and 'hpage'
> indicates the head page.)
> 
> When an error hits a hugetlb page, set_page_hwpoison_huge_page() sets
> PageHWPoison flags over all subpages of the hugetlb page in the
> ascending order of pfn. So if we don't have this TestSet, memory
> error handler can run more than once on concurrent errors when the
> 1st memory error hits (for example) the 100th subpage and the 2nd
> memory error hits (for example) the 50th subpage.

In your example, the 100th subage enter the memory
error handler firstly, and then it uses the 
set_page_hwpoison_huge_page to set all subpages
with PG_HWPoison flag, the 50th page handler waits
for grab the lock_page(hpage) now. 

When the 100th page handler unlock the 'hpage', 
the 50th grab it, and now the 'hapge' has been 
set with PG_HWPosison. So PageHWPoison micro 
will return true, and the following code will
be executed:

if (PageHWPoison(hpage)) {
    if ((hwpoison_filter(p) && TestClearPageHWPoison(p))
        || (p != hpage && TestSetPageHWPoison(hpage))) {
        atomic_long_sub(nr_pages, &num_poisoned_pages);
        unlock_page(hpage);
        return 0;
    }   
}

Now 'p' is 50th subpage, it doesn't equal the 
'hpage' obviously, so if we don't have TestSetPageHWPoison
here, it still will ignore the 50th error.
Why the memory error handler can run more than once?
Hope to receive from you!

thx,
Wang Xiaoqiang


> 
> Thanks,
> Naoya Horiguchi
> 
> > Signed-off-by: Wang Xiaoqiang <wangxq10@lzu.edu.cn>
> > ---
> >  mm/memory-failure.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> > index 1cf7f29..7794fd8 100644
> > --- a/mm/memory-failure.c
> > +++ b/mm/memory-failure.c
> > @@ -1115,7 +1115,7 @@ int memory_failure(unsigned long pfn, int
> > trapno, int flags) lock_page(hpage);
> >  			if (PageHWPoison(hpage)) {
> >  				if ((hwpoison_filter(p) &&
> > TestClearPageHWPoison(p))
> > -				    || (p != hpage &&
> > TestSetPageHWPoison(hpage))) {
> > +				    || p != hpage) {
> >  					atomic_long_sub(nr_pages,
> > &num_poisoned_pages); unlock_page(hpage);
> >  					return 0;
> > -- 
> > 1.7.10.4
> > 
> > 
> > 
> > --
> > thx!
> > Wang Xiaoqiang
> > 
