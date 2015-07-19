Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9D447280367
	for <linux-mm@kvack.org>; Sun, 19 Jul 2015 08:37:16 -0400 (EDT)
Received: by pacan13 with SMTP id an13so87789637pac.1
        for <linux-mm@kvack.org>; Sun, 19 Jul 2015 05:37:16 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id bi6si28674270pdb.129.2015.07.19.05.37.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Jul 2015 05:37:15 -0700 (PDT)
Date: Sun, 19 Jul 2015 15:37:02 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
Message-ID: <20150719123701.GD24238@esperanza>
References: <cover.1437303956.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <cover.1437303956.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, Jul 19, 2015 at 03:31:09PM +0300, Vladimir Davydov wrote:
> ---- PERFORMANCE EVALUATION ----
> 
> SPECjvm2008 (https://www.spec.org/jvm2008/) was used to evaluate the
> performance impact introduced by this patch set. Three runs were carried
> out:
> 
>  - base: kernel without the patch
>  - patched: patched kernel, the feature is not used
>  - patched-active: patched kernel, 1 minute-period daemon is used for
>    tracking idle memory
> 
> For tracking idle memory, idlememstat utility was used:
> https://github.com/locker/idlememstat
> 
> testcase            base            patched        patched-active
> 
> compiler       537.40 ( 0.00)%   532.26 (-0.96)%   538.31 ( 0.17)%
> compress       305.47 ( 0.00)%   301.08 (-1.44)%   300.71 (-1.56)%
> crypto         284.32 ( 0.00)%   282.21 (-0.74)%   284.87 ( 0.19)%
> derby          411.05 ( 0.00)%   413.44 ( 0.58)%   412.07 ( 0.25)%
> mpegaudio      189.96 ( 0.00)%   190.87 ( 0.48)%   189.42 (-0.28)%
> scimark.large   46.85 ( 0.00)%    46.41 (-0.94)%    47.83 ( 2.09)%
> scimark.small  412.91 ( 0.00)%   415.41 ( 0.61)%   421.17 ( 2.00)%
> serial         204.23 ( 0.00)%   213.46 ( 4.52)%   203.17 (-0.52)%
> startup         36.76 ( 0.00)%    35.49 (-3.45)%    35.64 (-3.05)%
> sunflow        115.34 ( 0.00)%   115.08 (-0.23)%   117.37 ( 1.76)%
> xml            620.55 ( 0.00)%   619.95 (-0.10)%   620.39 (-0.03)%
> 
> composite      211.50 ( 0.00)%   211.15 (-0.17)%   211.67 ( 0.08)%
> 
> time idlememstat:
> 
> 17.20user 65.16system 2:15:23elapsed 1%CPU (0avgtext+0avgdata 8476maxresident)k
> 448inputs+40outputs (1major+36052minor)pagefaults 0swaps

FWIW here are idle memory stats obtained during the SPECjvm2008 run:

 time    total     idle idle%  testcase
  1 m   179 MB     0 MB    0%
  2 m  1770 MB    48 MB    2%
  3 m  1777 MB   173 MB    9%  compiler.compiler warmup
  4 m  1750 MB   152 MB    8%  compiler.compiler warmup
  5 m  1751 MB   202 MB   11%  compiler.compiler
  6 m  1754 MB   252 MB   14%  compiler.compiler
  7 m  1754 MB   225 MB   12%  compiler.compiler
  8 m  1748 MB   126 MB    7%  compiler.compiler
  9 m  1752 MB   175 MB   10%  compiler.sunflow warmup
 10 m  1760 MB   168 MB    9%  compiler.sunflow warmup
 11 m  1759 MB   210 MB   11%  compiler.sunflow
 12 m  1762 MB   232 MB   13%  compiler.sunflow
 13 m  1761 MB   207 MB   11%  compiler.sunflow
 14 m  1775 MB   139 MB    7%  compiler.sunflow
 15 m  1775 MB   370 MB   20%  compress warmup
 16 m  1773 MB   515 MB   29%  compress warmup
 17 m  1770 MB   514 MB   29%  compress
 18 m  1761 MB   465 MB   26%  compress
 19 m  1750 MB   433 MB   24%  compress
 20 m  1772 MB   339 MB   19%  compress
 21 m  1794 MB   307 MB   17%  crypto.aes warmup
 22 m  1796 MB   325 MB   18%  crypto.aes warmup
 23 m  1798 MB   341 MB   19%  crypto.aes
 24 m  1798 MB   333 MB   18%  crypto.aes
 25 m  1797 MB   332 MB   18%  crypto.aes
 26 m  1798 MB   328 MB   18%  crypto.aes
 27 m  1798 MB   370 MB   20%  crypto.rsa warmup
 28 m  1793 MB   377 MB   21%  crypto.rsa warmup
 29 m  1786 MB   363 MB   20%  crypto.rsa
 30 m  1782 MB   360 MB   20%  crypto.rsa
 31 m  1781 MB   344 MB   19%  crypto.rsa
 32 m  1799 MB   328 MB   18%  crypto.rsa
 33 m  1799 MB   326 MB   18%  crypto.signverify warmup
 34 m  1799 MB   327 MB   18%  crypto.signverify warmup
 35 m  1799 MB   334 MB   18%  crypto.signverify
 36 m  1800 MB   339 MB   18%  crypto.signverify
 37 m  1800 MB   339 MB   18%  crypto.signverify
 38 m  1843 MB   323 MB   17%  crypto.signverify
 39 m  1903 MB   223 MB   11%
 40 m  1951 MB   225 MB   11%
 41 m  2498 MB   253 MB   10%
 42 m  2561 MB   494 MB   19%  derby warmup
 43 m  2565 MB   527 MB   20%  derby warmup
 44 m  2577 MB   574 MB   22%  derby
 45 m  2621 MB   580 MB   22%  derby
 46 m  2641 MB   536 MB   20%  derby
 47 m  2256 MB   316 MB   14%  derby
 48 m  2244 MB   427 MB   19%  mpegaudio warmup
 49 m  2225 MB   781 MB   35%  mpegaudio warmup
 50 m  2179 MB  1143 MB   52%  mpegaudio
 51 m  2067 MB  1297 MB   62%  mpegaudio
 52 m  1976 MB  1186 MB   60%  mpegaudio
 53 m  2756 MB  1118 MB   40%  mpegaudio
 54 m  3810 MB  1831 MB   48%  scimark.fft.large warmup
 55 m  3252 MB  1108 MB   34%  scimark.fft.large warmup
 56 m  2550 MB  1271 MB   49%  scimark.fft.large
 57 m  3835 MB  1643 MB   42%  scimark.fft.large
 58 m  3067 MB  1138 MB   37%  scimark.fft.large
 59 m  2072 MB  1103 MB   53%  scimark.fft.large
 60 m  2183 MB   799 MB   36%  scimark.fft.large
 61 m  2159 MB   568 MB   26%  scimark.lu.large warmup
 62 m  2333 MB   320 MB   13%  scimark.lu.large warmup
 63 m  2411 MB   447 MB   18%  scimark.lu.large warmup
 64 m  2646 MB   345 MB   13%  scimark.lu.large
 65 m  2687 MB   499 MB   18%  scimark.lu.large
 66 m  2691 MB   459 MB   17%  scimark.lu.large
 67 m  2703 MB   641 MB   23%  scimark.lu.large
 68 m  2735 MB  1077 MB   39%  scimark.lu.large
 69 m  2735 MB  2310 MB   84%  scimark.sor.large warmup
 70 m  2735 MB  1704 MB   62%  scimark.sor.large warmup
 71 m  2735 MB  2034 MB   74%  scimark.sor.large
 72 m  2735 MB  2390 MB   87%  scimark.sor.large
 73 m  2735 MB  2417 MB   88%  scimark.sor.large
 74 m  2735 MB  1366 MB   49%  scimark.sor.large
 75 m  2735 MB   985 MB   36%  scimark.sparse.large warmup
 76 m  2759 MB   925 MB   33%  scimark.sparse.large warmup
 77 m  2759 MB  1192 MB   43%  scimark.sparse.large
 78 m  2703 MB  1120 MB   41%  scimark.sparse.large
 79 m  2679 MB  1035 MB   38%  scimark.sparse.large
 80 m  2679 MB  1069 MB   39%  scimark.sparse.large
 81 m  2162 MB   863 MB   39%  scimark.sparse.large
 82 m  2109 MB   677 MB   32%  scimark.fft.small warmup
 83 m  2172 MB   637 MB   29%  scimark.fft.small warmup
 84 m  2220 MB   655 MB   29%  scimark.fft.small
 85 m  2264 MB   658 MB   29%  scimark.fft.small
 86 m  2316 MB   656 MB   28%  scimark.fft.small
 87 m  2529 MB   630 MB   24%  scimark.fft.small
 88 m  2840 MB   645 MB   22%  scimark.lu.small warmup
 89 m  2983 MB   652 MB   21%  scimark.lu.small warmup
 90 m  2983 MB   652 MB   21%  scimark.lu.small
 91 m  2983 MB   651 MB   21%  scimark.lu.small
 92 m  2984 MB   651 MB   21%  scimark.lu.small
 93 m  2984 MB   652 MB   21%  scimark.lu.small
 94 m  2984 MB  2114 MB   70%  scimark.sor.small warmup
 95 m  2984 MB  2796 MB   93%  scimark.sor.small warmup
 96 m  2984 MB  2823 MB   94%  scimark.sor.small
 97 m  2984 MB  2848 MB   95%  scimark.sor.small
 98 m  2984 MB  2817 MB   94%  scimark.sor.small
 99 m  2984 MB  1366 MB   45%  scimark.sor.small
100 m  2984 MB   664 MB   22%  scimark.sparse.small warmup
101 m  2984 MB   654 MB   21%  scimark.sparse.small warmup
102 m  2983 MB   663 MB   22%  scimark.sparse.small
103 m  2983 MB   652 MB   21%  scimark.sparse.small
104 m  2982 MB   651 MB   21%  scimark.sparse.small
105 m  2981 MB   640 MB   21%  scimark.sparse.small
106 m  2981 MB  2113 MB   70%  scimark.monte_carlo warmup
107 m  2981 MB  2831 MB   94%  scimark.monte_carlo warmup
108 m  2981 MB  2835 MB   95%  scimark.monte_carlo
109 m  2981 MB  2863 MB   96%  scimark.monte_carlo
110 m  2981 MB  2872 MB   96%  scimark.monte_carlo
111 m  2881 MB  1179 MB   40%  scimark.monte_carlo
112 m  2880 MB   777 MB   26%  serial warmup
113 m  2882 MB  1063 MB   36%  serial warmup
114 m  2880 MB  1066 MB   37%  serial
115 m  2880 MB  1064 MB   36%  serial
116 m  2882 MB  1064 MB   36%  serial
117 m  2887 MB  1042 MB   36%  serial
118 m  2886 MB  1118 MB   38%  sunflow warmup
119 m  2887 MB  1161 MB   40%  sunflow warmup
120 m  2887 MB  1166 MB   40%  sunflow
121 m  2887 MB  1170 MB   40%  sunflow
122 m  2886 MB  1172 MB   40%  sunflow
123 m  2896 MB  1159 MB   40%  sunflow
124 m  2906 MB  1132 MB   38%  xml.transform warmup
125 m  2907 MB  1136 MB   39%  xml.transform warmup
126 m  2907 MB  1137 MB   39%  xml.transform
127 m  2907 MB  1137 MB   39%  xml.transform
128 m  2907 MB  1134 MB   39%  xml.transform
129 m  2907 MB  1120 MB   38%  xml.transform
130 m  2895 MB   917 MB   31%  xml.validation warmup
131 m  2894 MB   706 MB   24%  xml.validation warmup
132 m  2903 MB   529 MB   18%  xml.validation
133 m  2907 MB   883 MB   30%  xml.validation
134 m  2894 MB  1013 MB   35%  xml.validation
135 m  2907 MB   853 MB   29%  xml.validation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
