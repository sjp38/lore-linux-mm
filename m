Date: Tue, 09 Jul 2002 09:08:35 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <134700000.1026230915@flay>
In-Reply-To: <3D2A7466.AD867DA7@zip.com.au>
References: <3D2A55D0.35C5F523@zip.com.au> <1214790647.1026163711@[10.10.2.3]> <3D2A7466.AD867DA7@zip.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> I can dig out the whole acg, and see what was calling copy_strings,
>> that might help give us a clue.
> 
> Well, it'll be exec().

Yup ;-) 

                 0.95   18.17   30186/90554       copy_strings_kernel [68]
                1.90   36.34   60368/90554       do_execve [15]
[36]     1.5    2.85   54.52   90554         copy_strings [36]
               40.55    0.00 2274831/2528191     _generic_copy_from_user [41]
                6.88    0.21 2274831/3762429     kmap_high [87]
                4.15    0.00 2274831/3762429     kunmap_high [105]
                2.12    0.00 2273886/4517587     strnlen_user [120]
                0.09    0.51   31139/4284514     _alloc_pages [24]
                0.00    0.00   31139/4284514     alloc_pages [369]


                0.00    0.00       2/30186       load_script <cycle 2> [553]
                0.00   19.12   30184/30186       do_execve [15]
[68]     0.5    0.00   19.12   30186         copy_strings_kernel [68]
                0.95   18.17   30186/90554       copy_strings [36]

> Updated patch below.  We don't need an atomic kmap in copy_strings
> at all.  kmap is the right thing to do, but just be smarter about it.
> Hanging onto the existing kmap in there reduces the number of kmap()
> calls by a factor of 32 across a kernel compile.

Sounds about right, looking at the data above.
 
> But still no aggregate speedup.

Now that really is odd. Will get you some more numbers.

M.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
