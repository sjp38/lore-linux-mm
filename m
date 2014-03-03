Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f170.google.com (mail-ve0-f170.google.com [209.85.128.170])
	by kanga.kvack.org (Postfix) with ESMTP id 166346B0038
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 18:08:28 -0500 (EST)
Received: by mail-ve0-f170.google.com with SMTP id pa12so4450812veb.29
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 15:08:27 -0800 (PST)
Received: from mail-ve0-x230.google.com (mail-ve0-x230.google.com [2607:f8b0:400c:c01::230])
        by mx.google.com with ESMTPS id tt2si3993712vdc.22.2014.03.03.15.08.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 15:08:27 -0800 (PST)
Received: by mail-ve0-f176.google.com with SMTP id cz12so4348147veb.21
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 15:08:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140303143834.90ebe8ec5c6a369e54a599ec@linux-foundation.org>
References: <1393625931-2858-1-git-send-email-quning@google.com>
 <CACQD4-5U3P+QiuNKzt5+VdDDi0ocphR+Jh81eHqG6_+KeaHyRw@mail.gmail.com>
 <20140228174150.8ff4edca.akpm@linux-foundation.org> <CACQD4-7UUDMeXdR-NaAAXvk-NRYqW7mHJkjDUM=JRvL54b_Xsg@mail.gmail.com>
 <CACQD4-5SmUf+krLbef9Yg9HhJ-ipT2QKKq-NW=2C6G=XwXcMcQ@mail.gmail.com> <20140303143834.90ebe8ec5c6a369e54a599ec@linux-foundation.org>
From: Ning Qu <quning@gmail.com>
Date: Mon, 3 Mar 2014 15:07:47 -0800
Message-ID: <CACQD4-4M9PkJ7cg24fLZ6ow=5hjhpHzymmfO1LU5x9ZBK-AsJA@mail.gmail.com>
Subject: Re: [PATCH 0/1] mm, shmem: map few pages around fault address if they
 are in page cache
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Actually this one is just using the generic functions provided in
Kirill's patch.

And Kirill just sent another email earlier with two fixes reported by
Hugh and I.

So it doesn't change anything in this patch. I will update the log and
work on the

experiment results. I already asked Kirill command line, so I can have a

apple-to-apple comparison then. I will update the patch with new results soon.

Sorry about the mess-up previously. I should have asked Kirill about the test

in the first place.


Best wishes,
-- 
Ning Qu


On Mon, Mar 3, 2014 at 2:38 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 28 Feb 2014 22:27:04 -0800 Ning Qu <quning@gmail.com> wrote:
>
>> On Fri, Feb 28, 2014 at 10:10 PM, Ning Qu <quning@gmail.com> wrote:
>> > Yes, I am using the iozone -i 0 -i 1. Let me try the most simple test
>> > as you mentioned.
>> > Best wishes,
>> > --
>> > Ning Qu
>> >
>> >
>> > On Fri, Feb 28, 2014 at 5:41 PM, Andrew Morton
>> > <akpm@linux-foundation.org> wrote:
>> >> On Fri, 28 Feb 2014 16:35:16 -0800 Ning Qu <quning@gmail.com> wrote:
>> >>
>> >>
>> >> int main(int argc, char *argv[])
>> >> {
>> >>         char *p;
>> >>         int fd;
>> >>         unsigned long idx;
>> >>         int sum = 0;
>> >>
>> >>         fd = open("foo", O_RDONLY);
>> >>         if (fd < 0) {
>> >>                 perror("open");
>> >>                 exit(1);
>> >>         }
>> >>         p = mmap(NULL, 1 * G, PROT_READ, MAP_PRIVATE, fd, 0);
>> >>         if (p == MAP_FAILED) {
>> >>                 perror("mmap");
>> >>                 exit(1);
>> >>         }
>> >>
>> >>         for (idx = 0; idx < 1 * G; idx += 4096)
>> >>                 sum += p[idx];
>> >>         printf("%d\n", sum);
>> >>         exit(0);
>> >> }
>> >>
>> >> z:/home/akpm> /usr/bin/time ./a.out
>> >> 0
>> >> 0.05user 0.33system 0:00.38elapsed 99%CPU (0avgtext+0avgdata 4195856maxresident)k
>> >> 0inputs+0outputs (0major+262264minor)pagefaults 0swaps
>> >>
>> >> z:/home/akpm> dc
>> >> 16o
>> >> 262264 4 * p
>> >> 1001E0
>> >>
>> >> That's close!
>
> OK, I'm repairing your top-posting here.  It makes it unnecessarily
> hard to conduct a conversation - please just don't do it.
>
>> Yes, the simple test does verify that the page fault number are
>> correct with the patch. So my previous results are from those command
>> lines, which also show some performance improvement with this change
>> in tmpfs.
>>
>> sequential access
>> /usr/bin/time -a ./iozone -B s 8g -i 0 -i 1
>>
>> random access
>> /usr/bin/time -a ./iozone -B s 8g -i 0 -i 2
>
> I don't understand your point here.
>
> Running my simple test app with and without Kirill's
> mm-introduce-vm_ops-map_pages and
> mm-implement-map_pages-for-page-cache, minor faults are reduced 16x
> when the file is cached, as expected:
>
> 0.02user 0.22system 0:00.24elapsed 97%CPU (0avgtext+0avgdata 4198080maxresident)k
> 0inputs+0outputs (0major+16433minor)pagefaults 0swaps
>
>
> When the file is uncached, results are peculiar:
>
> 0.00user 2.84system 0:50.90elapsed 5%CPU (0avgtext+0avgdata 4198096maxresident)k
> 0inputs+0outputs (1major+49666minor)pagefaults 0swaps
>
> That's approximately 3x more minor faults.  I thought it might be due
> to the fact that userspace pagefaults and disk IO completions are both
> working in the same order through the same pages, so the pagefaults
> keep stumbling across not-yet-completed pages.  So I attempted to
> complete the pages in reverse order:
>
> --- a/fs/mpage.c~a
> +++ a/fs/mpage.c
> @@ -41,12 +41,16 @@
>   * status of that page is hard.  See end_buffer_async_read() for the details.
>   * There is no point in duplicating all that complexity.
>   */
> +#define bio_for_each_segment_all_reverse(bvl, bio, i)                  \
> +       for (i = 0, bvl = (bio)->bi_io_vec + (bio)->bi_vcnt - 1;        \
> +       i < (bio)->bi_vcnt; i++, bvl--)
> +
>  static void mpage_end_io(struct bio *bio, int err)
>  {
>         struct bio_vec *bv;
>         int i;
>
> -       bio_for_each_segment_all(bv, bio, i) {
> +       bio_for_each_segment_all_reverse(bv, bio, i) {
>                 struct page *page = bv->bv_page;
>
>                 if (bio_data_dir(bio) == READ) {
>
> But that made no difference.  Maybe I got the wrong BIO completion
> routine, but I don't think so (it's ext3).  Probably my theory is
> wrong.
>
> Anyway, could you please resend your patch with Hugh's fix and with a
> more carefully written and more accurate changelog?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
